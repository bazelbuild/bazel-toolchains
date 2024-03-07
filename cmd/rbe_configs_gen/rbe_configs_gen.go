// Copyright 2021 The Bazel Authors. All rights reserved.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//    http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//
// Binary rbe_configs_gen provides the ability to generate toolchain targets along with a default
// platform target to configure Bazel to run actions remotely.
package main

import (
	"context"
	"flag"
	"fmt"
	"log"
	"os"
	"strings"

	"github.com/bazelbuild/bazel-toolchains/pkg/monitoring"
	"github.com/bazelbuild/bazel-toolchains/pkg/rbeconfigsgen"
)

var (
	// Mandatory input arguments.
	toolchainContainer = flag.String("toolchain_container", "", "Repository path to toolchain image to generate configs for. E.g., l.gcr.io/google/rbe-ubuntu16-04:latest")
	execOS             = flag.String("exec_os", "", "The OS (linux|windows) of the toolchain container image a.k.a, the execution platform in Bazel.")
	targetOS           = flag.String("target_os", "", "The OS (linux|windows) artifacts built will target a.k.a, the target platform in Bazel.")
	dockerPlatform     = flag.String("docker_platform", "", "(Optional) Set platform when creating container, if given the Docker server is multi-platform capable.")

	// Optional input arguments.
	bazelVersion = flag.String("bazel_version", "", "(Optional) Bazel release version to generate configs for. E.g., 4.0.0. If unspecified, the latest available Bazel release is picked.")
	bazelPath    = flag.String("bazel_path", "", "(Optional) Path to preinstalled Bazel within the container. If unspecified, Bazelisk will be downloaded and installed.")

	// Arguments affecting output generation not specific to either C++ or Java Configs.
	outputTarball    = flag.String("output_tarball", "", "(Optional) Path where a tarball with the generated configs will be created.")
	outputSrcRoot    = flag.String("output_src_root", "", "(Optional) Path to root directory of Bazel repository where generated configs should be copied to. Configs aren't copied if this is blank. Use '.' to specify the current directory.")
	outputConfigPath = flag.String("output_config_path", "", "(Optional) Path relative to what was specified to --output_src_root where configs will be extracted. Defaults to root if unspecified. --output_src_root is mandatory if this argument is specified.")
	outputManifest   = flag.String("output_manifest", "", "(Optional) Generate a JSON file with details about the generated configs.")

	// Optional input arguments that affect config generation for either C++ or Java configs.
	genCppConfigs       = flag.Bool("generate_cpp_configs", true, "(Optional) Generate C++ configs. Defaults to true.")
	cppEnvJSON          = flag.String("cpp_env_json", "", "(Optional) JSON file containing a str -> str dict of environment variables to be set when generating C++ configs inside the toolchain container. This replaces any exec OS specific defaults that would usually be applied.")
	cppToolchainTarget  = flag.String("cpp_toolchain_target", "", "(Optional) Set the CPP toolchain target. When exec_os is linux, the default is cc-compiler-k8. When exec_os is windows, the default is cc-compiler-x64_windows.")
	genJavaConfigs      = flag.Bool("generate_java_configs", true, "(Optional) Generate Java configs. Defaults to true.")
	javaUseLocalRuntime = flag.Bool("java_use_local_runtime", false, "(Optional) Make the generated java toolchain use the new local_java_runtime rule instead of java_runtime. Otherwise, the Bazel version will be used to infer which rule to use.")
	execConstraints     = flag.String("exec_constraints", "", "(Optional) Set the platform constraint values. Use ',' to seperate multiple values.")

	// Other misc arguments.
	tempWorkDir = flag.String("temp_work_dir", "", "(Optional) Temporary directory to use to store intermediate files. Defaults to a temporary directory automatically allocated by the OS. The temporary working directory is deleted at the end unless --cleanup=false is specified.")
	cleanup     = flag.Bool("cleanup", true, "(Optional) Stop running container & delete intermediate files. Defaults to true. Set to false for debugging.")

	// Google Cloud Monitoring options. Used by internal automation only.
	enableMonitoring      = flag.Bool("enable_monitoring", false, "(Optional) Enables reporting reporting results to Google Cloud Monitoring. Defaults to false.")
	monitoringProjectID   = flag.String("monitoring_project_id", "", "GCP Project ID where monitoring results will be reported. Required if --enable_monitoring is true.")
	monitoringDockerImage = flag.String("monitoring_docker_image", "", "Name of the toolchain docker image to be reported as a string label to monitoring. Required if --enable_monitoring is true.")
)

// printFlag prints flag values with the intent of allowing easy copy paste of flags to rerun this
// binary. Printing defaults are skipped as much as possible to avoid cluttering the output.
func printFlags() {
	log.Println("rbe_configs_gen.go \\")
	log.Printf("--toolchain_container=%q \\", *toolchainContainer)
	log.Printf("--exec_os=%q \\", *execOS)
	log.Printf("--target_os=%q \\", *targetOS)
	log.Printf("--bazel_version=%q \\", *bazelVersion)
	if len(*bazelPath) != 0 {
		log.Printf("--bazel_path=%q \\", *bazelPath)
	}
	if len(*outputTarball) != 0 {
		log.Printf("--output_tarball=%q \\", *outputTarball)
	}
	if len(*outputSrcRoot) != 0 {
		log.Printf("--output_src_root=%q \\", *outputSrcRoot)
	}
	if len(*outputConfigPath) != 0 {
		log.Printf("--output_config_path=%q \\", *outputConfigPath)
	}
	if len(*outputManifest) != 0 {
		log.Printf("--output_manifest=%q \\", *outputManifest)
	}
	if !(*genCppConfigs) {
		log.Printf("--generate_cpp_configs=%v \\", *genCppConfigs)
	}
	if len(*cppEnvJSON) != 0 {
		log.Printf("--cpp_env_json=%q \\", *cppEnvJSON)
	}
	if !(*genJavaConfigs) {
		log.Printf("--generate_java_configs=%v \\", *genJavaConfigs)
	}
	if *javaUseLocalRuntime {
		log.Printf("--java_use_local_runtime=%v \\", *javaUseLocalRuntime)
	}
	if len(*tempWorkDir) != 0 {
		log.Printf("--temp_work_dir=%q \\", *tempWorkDir)
	}
	if !(*cleanup) {
		log.Printf("--cleanup=%v \\", *cleanup)
	}
	if *enableMonitoring {
		log.Printf("--enable_monitoring=%v \\", *enableMonitoring)
	}
	if len(*monitoringProjectID) != 0 {
		log.Printf("--monitoring_project_id=%q \\", *monitoringProjectID)
	}
	if len(*monitoringDockerImage) != 0 {
		log.Printf("--monitoring_docker_image=%q \\", *monitoringDockerImage)
	}
}

func initMonitoringClient(ctx context.Context) (*monitoring.Client, error) {
	if !(*enableMonitoring) {
		return nil, nil
	}
	if len(*monitoringProjectID) == 0 {
		return nil, fmt.Errorf("--monitoring_project_id is required because --enable_monitoring is true")
	}
	if len(*monitoringDockerImage) == 0 {
		return nil, fmt.Errorf("--monitoring_docker_image is required because --enable_monitoring is true")
	}
	c, err := monitoring.NewClient(ctx, *monitoringProjectID)
	if err != nil {
		return nil, fmt.Errorf("unable to initialize the monitoring client: %w", err)
	}
	return c, nil
}

// genConfigs is just a wrapper for the config generation code so that the caller can report
// results if monitoring is enabled before exiting.
func genConfigs(o rbeconfigsgen.Options) error {
	if err := o.ApplyDefaults(o.ExecOS); err != nil {
		return fmt.Errorf("failed to apply default options for OS name %q specified to --exec_os: %w", *execOS, err)
	}
	if err := o.Validate(); err != nil {
		return fmt.Errorf("Failed to validate command line arguments: %v", err)
	}
	if err := rbeconfigsgen.Run(o); err != nil {
		return fmt.Errorf("Config generation failed: %v", err)
	}
	return nil
}

func main() {
	flag.Parse()
	printFlags()

	ctx := context.Background()
	mc, err := initMonitoringClient(ctx)
	if err != nil {
		log.Fatalf("Failed to initialize monitoring: %v", err)
	}

	platformParams := new(rbeconfigsgen.PlatformToolchainsTemplateParams)
	platformParams.ExecConstraints = strings.Split(*execConstraints, ",")

	o := rbeconfigsgen.Options{
		BazelVersion:           *bazelVersion,
		BazelPath:              *bazelPath,
		ToolchainContainer:     *toolchainContainer,
		DockerPlatform:         *dockerPlatform,
		ExecOS:                 *execOS,
		TargetOS:               *targetOS,
		OutputTarball:          *outputTarball,
		OutputSourceRoot:       *outputSrcRoot,
		OutputConfigPath:       *outputConfigPath,
		OutputManifest:         *outputManifest,
		GenCPPConfigs:          *genCppConfigs,
		CppGenEnvJSON:          *cppEnvJSON,
		PlatformParams:         platformParams,
		CPPToolchainTargetName: *cppToolchainTarget,
		GenJavaConfigs:         *genJavaConfigs,
		JavaUseLocalRuntime:    *javaUseLocalRuntime,
		TempWorkDir:            *tempWorkDir,
		Cleanup:                *cleanup,
	}

	result := true
	if err := genConfigs(o); err != nil {
		result = false
		log.Printf("Config generation failed: %v", err)
	} else {
		log.Printf("Config generation was successful.")
	}
	// Monitoring is optional and used for internal alerting by the owners of this repo only.
	if mc != nil {
		if err := mc.ReportToolchainConfigsGeneration(ctx, *monitoringDockerImage, result); err != nil {
			log.Fatalf("Failed to report config result to monitoring: %v", err)
		}
	}
	if !result {
		os.Exit(1)
	}
}
