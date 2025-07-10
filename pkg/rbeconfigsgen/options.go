// Copyright 2021 The Bazel Authors. All rights reserved.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//	http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//
// Package rbeconfigsgen contains utilities to generate C++ & Java Toolchain configs for Bazel to be
// used to run RBE builds
package rbeconfigsgen

import (
	"fmt"
	"log"
	"path"
	"strings"

	"github.com/bazelbuild/bazelisk/core"
	"github.com/bazelbuild/bazelisk/repositories"
)

// Options are the options to tweak Bazel C++/Java Toolchain config generation.
type Options struct {
	// BazelVersion is the version of Bazel to generate configs for. If unset, the latest Bazel
	// version is automatically populated into this field when Validate() is called.
	BazelVersion string
	// BazelPath is the path within the container where Bazel is preinstalled. If unspecified,
	// Bazelisk will be downloaded and installed.
	BazelPath string
	// ToolchainContainer is the docker image of the toolchain container to generate configs for.
	ToolchainContainer string
	// Specify --platform when executing docker create.
	DockerPlatform string
	// ExecOS is the OS of the toolchain container image or the OS in which the build actions will
	// execute.
	ExecOS string
	// TargetOS is the OS to be used as the target platform in the generated platform rule. This
	// is the OS that artifacts built by Bazel will be executed on.
	TargetOS string
	// OutputTarball is the path at with a tarball will be generated containing the C++/Java
	// configs.
	OutputTarball string
	// OutputSourceRoot is the path where the root of the source repository where generated configs
	// should be copied to. This directory is expected to have a Bazel WORKSPACE file.
	OutputSourceRoot string
	// OutputConfigPath is the path relative to OutputSourceRoot where the generated configs will
	// be copied to.
	OutputConfigPath string
	// OutputManifest is a path where a text file containing details about the generated configs.
	// The manifest aims to be easily parseable by shell utilities like grep/sed.
	OutputManifest string
	// PlatformParams specify platform specific constraints used to generate a BUILD file with the
	// toolchain & platform targets in the generated configs. This is set to default values and not
	// directly configurable.
	PlatformParams *PlatformToolchainsTemplateParams

	// C++ Config generation options.
	// GenCPPConfigs determines whether C++ configs are generated.
	GenCPPConfigs bool
	// CPPConfigTargets are the Bazel targets that will be used to make Bazel auto-generated C++
	// configs.
	// This field can be auto-populated with a default value. See DefaultExecOptions below.
	CPPConfigTargets []string
	// CPPConfigRepo is the name of the Bazel external repo (i.e., the repo name without the '@')
	// whose Bazel build output directory will be used to extract generated C++ config files.
	// This field can be auto-populated with a default value. See DefaultExecOptions below.
	CPPConfigRepo string
	// CppBazelCmd is the Bazel command that'll be executed (build|query) on CppConfigTargets to
	// generate CppConfigTargets. So if CppConfigTargets is @foo//:blah & CppBazelCmd is build,
	// this tool will run bazel build @foo//:blah.
	// This field can be auto-populated with a default value. See DefaultExecOptions below.
	CppBazelCmd string
	// CppGenEnv are the environment variables that'll be set when running the Bazel command to
	// generate C++ configs inside the toolchain container. Only one of CppGenEnv or CppGenEnvJSON
	// can be specified.
	CppGenEnv map[string]string
	// CppGenEnvJSON is a JSON file with environment variables that'll be set when running the Bazel
	// command to generate C++ configs inside the toolchain container. Only one of CppGenEnv or
	// CppGenEnvJSON can be specified.
	CppGenEnvJSON string
	// CPPToolchainTarget is the toolchain to be used by the cpp configs.
	CPPToolchainTargetName string

	// Java config generation options.
	// GenJavaConfigs determines whether Java configs are generated.
	GenJavaConfigs bool
	// JavaUseLocalRuntime forces the generated java toolchain to use the local_java_runtime
	// rule instead of java_runtime. Otherwise, the Bazel version will be used to infer which rule
	// to use. Older Bazel versions use java_runtime.
	JavaUseLocalRuntime bool
	// TempWorkDir is a temporary directory that will be used by this tool to store intermediate
	// files. If unspecified, a temporary directory will be requested from the OS.
	TempWorkDir string
	// Cleanup determines whether the running container & intermediate files will be deleted once
	// config generation is done. Setting it to false is useful for debugging intermediate state.
	Cleanup bool
}

// DefaultOptions are some option values that are populated as default values for certain fields
// of "Options". See "Options" for explanation on what the fields mean.
type DefaultOptions struct {
	PlatformParams         PlatformToolchainsTemplateParams
	CPPConfigTargets       []string
	CPPConfigRepo          string
	CppBazelCmd            string
	CppGenEnv              map[string]string
	CPPToolchainTargetName string
}

const (
	// OSLinux represents Linux when selecting platforms.
	OSLinux = "linux"
	// OSWindows represents Windows when selecting platforms.
	OSWindows = "windows"
)

var (
	validOS = []string{
		OSLinux,
		OSWindows,
	}

	// DefaultExecOptions is a map from the ExecOS to default values for certain fields in Options
	// that vary based on the execution environment.
	DefaultExecOptions = map[string]DefaultOptions{
		OSLinux: {
			PlatformParams: PlatformToolchainsTemplateParams{
				ExecConstraints: []string{
					"@platforms//os:linux",
					"@platforms//cpu:x86_64",
					"@bazel_tools//tools/cpp:clang",
				},
				TargetConstraints: []string{
					"@platforms//os:linux",
					"@platforms//cpu:x86_64",
				},
				OSFamily: "Linux",
			},
			CPPConfigTargets: []string{"@local_config_cc//..."},
			CPPConfigRepo:    "local_config_cc",
			CppBazelCmd:      "build",
			CppGenEnv: map[string]string{
				"ABI_LIBC_VERSION":    "glibc_2.19",
				"ABI_VERSION":         "clang",
				"BAZEL_COMPILER":      "clang",
				"BAZEL_HOST_SYSTEM":   "i686-unknown-linux-gnu",
				"BAZEL_TARGET_CPU":    "k8",
				"BAZEL_TARGET_LIBC":   "glibc_2.19",
				"BAZEL_TARGET_SYSTEM": "x86_64-unknown-linux-gnu",
				"CC":                  "clang",
				"CC_TOOLCHAIN_NAME":   "linux_gnu_x86",
			},
			CPPToolchainTargetName: "cc-compiler-k8",
		},
		OSWindows: {
			PlatformParams: PlatformToolchainsTemplateParams{
				ExecConstraints: []string{
					"@platforms//os:windows",
					"@platforms//cpu:x86_64",
				},
				TargetConstraints: []string{
					"@platforms//os:windows",
					"@platforms//cpu:x86_64",
				},
				OSFamily: "Windows",
			},
			CPPConfigTargets:       []string{"@local_config_cc//..."},
			CPPConfigRepo:          "local_config_cc",
			CppBazelCmd:            "query",
			CPPToolchainTargetName: "cc-compiler-x64_windows",
		},
	}
)

func strListContains(l []string, s string) bool {
	for _, i := range l {
		if i == s {
			return true
		}
	}
	return false
}

// ApplyDefaults applies platform specific default values to the given options for the given
// OS.
func (o *Options) ApplyDefaults(os string) error {
	dopts, ok := DefaultExecOptions[os]
	if !ok {
		return fmt.Errorf("got unknown OS %q, want one of %s", os, strings.Join(validOS, ", "))
	}

	if o.PlatformParams == nil {
		o.PlatformParams = new(PlatformToolchainsTemplateParams)
	}

	if len(o.PlatformParams.ExecConstraints) == 0 {
		o.PlatformParams.ExecConstraints = dopts.PlatformParams.ExecConstraints
	}
	o.PlatformParams.TargetConstraints = dopts.PlatformParams.TargetConstraints
	o.PlatformParams.OSFamily = dopts.PlatformParams.OSFamily

	o.CPPConfigTargets = dopts.CPPConfigTargets
	o.CPPConfigRepo = dopts.CPPConfigRepo
	o.CppBazelCmd = dopts.CppBazelCmd
	// Only apply C++ env defaults if the options didn't already specify defaults and no JSON file
	// to read environment variables from was specified.
	if len(o.CppGenEnv) == 0 && len(o.CppGenEnvJSON) == 0 {
		o.CppGenEnv = dopts.CppGenEnv
	}
	if o.CPPToolchainTargetName == "" {
		o.CPPToolchainTargetName = dopts.CPPToolchainTargetName
	}
	return nil
}

// latestBazelVersion uses Bazelisk to determine the latest available Bazel version.
func latestBazelVersion() (string, error) {
	r := core.CreateRepositories(&repositories.GCSRepo{}, nil, nil, nil, false)
	v, _, err := r.ResolveVersion("", "", "latest")
	if err != nil {
		return "", fmt.Errorf("unable to determine the latest available Bazel release using Bazelisk: %w", err)
	}
	return v, nil
}

// Validate verifies that mandatory arguments were provided and argument values don't conflict in
// certain cases.
func (o *Options) Validate() error {
	if o.BazelVersion == "" {
		v, err := latestBazelVersion()
		if err != nil {
			return fmt.Errorf("BazelVersion wasn't specified and was unable to determine the latest available Bazel version: %w", err)
		}
		o.BazelVersion = v
	}
	if o.ToolchainContainer == "" {
		return fmt.Errorf("ToolchainContainer was not specified")
	}
	if o.ExecOS == "" {
		return fmt.Errorf("ExecOS was not specified")
	}
	if !strListContains(validOS, o.ExecOS) {
		return fmt.Errorf("invalid exec_os, got %q, want one of %s", o.ExecOS, strings.Join(validOS, ", "))
	}
	if o.TargetOS == "" {
		return fmt.Errorf("TargetOS was not specified")
	}
	if !strListContains(validOS, o.TargetOS) {
		return fmt.Errorf("invalid TargetOS, got %q, want one of %s", o.TargetOS, strings.Join(validOS, ", "))
	}
	if o.OutputTarball == "" && o.OutputSourceRoot == "" {
		return fmt.Errorf("atleast one of OutputTarball or OutputSourceRoot must be specified or this tool won't generate any output")
	}
	if o.OutputSourceRoot == "" && o.OutputConfigPath != "" {
		return fmt.Errorf("OutputSourceRoot is required because OutputConfigPath was specified")
	}
	if path.IsAbs(o.OutputConfigPath) {
		return fmt.Errorf("OutputConfigPath should be a relative path")
	}
	if o.PlatformParams == nil {
		return fmt.Errorf("PlatformParams was not initialized")
	}
	if !o.GenCPPConfigs && !o.GenJavaConfigs {
		return fmt.Errorf("both GenCPPConfigs & GenJavaConfigs were set to false which means there's no configs to generate")
	}
	if o.GenCPPConfigs && len(o.CPPConfigTargets) == 0 {
		return fmt.Errorf("GenCPPConfigs was true but CppConfigTargets was not specified")
	}
	if o.GenCPPConfigs && len(o.CppBazelCmd) == 0 {
		return fmt.Errorf("GenCPPConfigs was true but CppBazelCmd was not specified")
	}
	if len(o.CppGenEnv) != 0 && len(o.CppGenEnvJSON) != 0 {
		return fmt.Errorf("only one of CppGenEnv=%v or CppGenEnvJSON=%q must be specified", o.CppGenEnv, o.CppGenEnvJSON)
	}
	log.Printf("rbeconfigsgen.Options:")
	log.Printf("BazelVersion=%q", o.BazelVersion)
	log.Printf("ToolchainContainer=%q", o.ToolchainContainer)
	log.Printf("ExecOS=%q", o.ExecOS)
	log.Printf("TargetOS=%q", o.TargetOS)
	log.Printf("DockerPlatform=%q", o.DockerPlatform)
	log.Printf("OutputTarball=%q", o.OutputTarball)
	log.Printf("OutputSourceRoot=%q", o.OutputSourceRoot)
	log.Printf("OutputConfigPath=%q", o.OutputConfigPath)
	log.Printf("OutputManifest=%q", o.OutputManifest)
	log.Printf("PlatformParams=%v", *o.PlatformParams)
	log.Printf("GenCPPConfigs=%v", o.GenCPPConfigs)
	log.Printf("CPPConfigTargets=%v", o.CPPConfigTargets)
	log.Printf("CPPConfigRepo=%q", o.CPPConfigRepo)
	log.Printf("CppBazelCmd=%q", o.CppBazelCmd)
	log.Printf("CppGenEnv=%v", o.CppGenEnv)
	log.Printf("CppGenEnvJSON=%q", o.CppGenEnvJSON)
	log.Printf("GenJavaConfigs=%v", o.GenJavaConfigs)
	log.Printf("JavaUseLocalRuntime=%v", o.JavaUseLocalRuntime)
	log.Printf("TempWorkDir=%q", o.TempWorkDir)
	log.Printf("Cleanup=%v", o.Cleanup)
	return nil
}
