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
package rbeconfigsgen

import (
	"os"
	"path/filepath"
	"strings"
	"testing"
	"text/template"
)

func TestGenCppToolchainTarget(t *testing.T) {
	tests := []struct {
		name string
		want string
		opt  *Options
	}{
		{
			name: "No options, linux, choose default",
			want: "//cc:cc-compiler-k8",
			opt: &Options{
				ExecOS: "linux",
			},
		}, {
			name: "No options, windows, choose default",
			want: "//cc:cc-compiler-x64_windows",
			opt: &Options{
				ExecOS: "windows",
			},
		}, {
			name: "Windows pick compiler",
			want: "//cc:cc-compiler-x64_windows_mingw",
			opt: &Options{
				ExecOS:                 "windows",
				CPPToolchainTargetName: "cc-compiler-x64_windows_mingw",
			},
		}, {
			name: "Linux pick output path",
			want: "//configs/foo/bar/cc:cc-compiler-k8",
			opt: &Options{
				ExecOS:           "linux",
				OutputConfigPath: "configs/foo/bar",
			},
		}, {
			name: "Windows pick output path and compiler",
			want: "//configs/fizz/buzz/cc:foobar-cc-good",
			opt: &Options{
				ExecOS:                 "windows",
				OutputConfigPath:       "configs/fizz/buzz",
				CPPToolchainTargetName: "foobar-cc-good",
			},
		}, {
			name: "Windows pick backslash style path and compiler",
			want: "//configs/fizz/buzz/cc:foobar-cc-good",
			opt: &Options{
				ExecOS:                 "windows",
				OutputConfigPath:       "configs\\fizz\\buzz",
				CPPToolchainTargetName: "foobar-cc-good",
			},
		},
	}

	for _, tc := range tests {
		tc := tc
		t.Run(tc.name, func(t *testing.T) {
			t.Parallel()
			if err := tc.opt.ApplyDefaults(tc.opt.ExecOS); err != nil {
				t.Fatalf("ApplyDefaults: Failed to apply defaults=%v", err)
			}
			// We skip validation since we don't set all options required for
			// regular execution.
			if got := genCppToolchainTarget(tc.opt); got != tc.want {
				t.Fatalf("GenCppToolchainTarget: %v, wanted %v", got, tc.want)
			}
		})
	}
}

func TestGetJavaTemplate(t *testing.T) {
	tests := []struct {
		name string
		want *template.Template
		opt  *Options
	}{
		{
			name: "bazel 4, choose legacy",
			want: legacyJavaBuildTemplate,
			opt: &Options{
        BazelVersion: "4.0.0",
      },
		},
		{
			name: "bazel 5, choose BazelLt7",
			want: javaBuildTemplateLt7,
			opt: &Options{
        BazelVersion: "5.0.0",
			},
		},
		{
			name: "bazel 7, choose latest",
			want: javaBuildTemplate,
			opt: &Options{
        BazelVersion: "7.0.0",
			},
		},
		{
			name: "bazel 7-pre, choose latest",
			want: javaBuildTemplate,
			opt: &Options{
        BazelVersion: "7.0.0-pre.20230724.1",
			},
		},
		{
			name: "useLocalRuntime forced, choose latest",
			want: javaBuildTemplate,
			opt: &Options{
			  JavaUseLocalRuntime: true,
			},
		},
		{
			name: "useLocalRuntime forced, bazel 4, choose BazelLt7",
			want: javaBuildTemplateLt7,
			opt: &Options{
			  BazelVersion: "4.0.0",
			  JavaUseLocalRuntime: true,
			},
		},
		{
			name: "useLocalRuntime forced, bazel 5, choose BazelLt7",
			want: javaBuildTemplateLt7,
			opt: &Options{
			  BazelVersion: "5.0.0",
			  JavaUseLocalRuntime: true,
			},
		},
		{
			name: "useLocalRuntime forced, bazel 6, choose BazelLt7",
			want: javaBuildTemplateLt7,
			opt: &Options{
			  BazelVersion: "6.0.0",
			  JavaUseLocalRuntime: true,
			},
		},
		{
			name: "useLocalRuntime forced, bazel 7, choose latest",
			want: javaBuildTemplate,
			opt: &Options{
			  BazelVersion: "7.0.0",
			  JavaUseLocalRuntime: true,
			},
		},
		{
			name: "useLocalRuntime forced, bazel 7-pre, choose latest",
			want: javaBuildTemplate,
			opt: &Options{
			  BazelVersion: "7.0.0-pre.20200202",
			  JavaUseLocalRuntime: true,
			},
		},
		{
			name: "development version, choose latest",
			want: javaBuildTemplate,
			opt: &Options{
			  BazelVersion: "development version",
			},
		},
	}

	for _, tc := range tests {
		tc := tc
		t.Run(tc.name, func(t *testing.T) {
			t.Parallel()
			// We skip validation since we don't set all options required for
			// regular execution.
			got, err := getJavaTemplate(tc.opt);
			if err != nil {
			  t.Fatalf("getJavaTemplate failed: %v, wanted: %v", err, tc.want)
			} else if got != tc.want {
				t.Fatalf("getJavaTemplate: %v, wanted %v", got, tc.want)
			}
		})
	}
}

func TestDetectBazelVersion(t *testing.T) {
	tmpDir := t.TempDir()
	
	// Test case 1: Valid version output
	bazelScript := filepath.Join(tmpDir, "bazel_valid")
	err := os.WriteFile(bazelScript, []byte("#!/bin/sh\necho 'bazel 5.4.0'\n"), 0755)
	if err != nil {
		t.Fatalf("Failed to write test script: %v", err)
	}
	
	got, err := detectBazelVersion(bazelScript)
	if err != nil {
		t.Errorf("detectBazelVersion failed: %v", err)
	}
	if got != "5.4.0" {
		t.Errorf("detectBazelVersion = %q, want 5.4.0", got)
	}
	
	// Test case 2: Custom/development version output
	bazelScriptDev := filepath.Join(tmpDir, "bazel_dev")
	err = os.WriteFile(bazelScriptDev, []byte("#!/bin/sh\necho 'bazel development version'\n"), 0755)
	if err != nil {
		t.Fatalf("Failed to write test script: %v", err)
	}
	
	got, err = detectBazelVersion(bazelScriptDev)
	if err != nil {
		t.Errorf("detectBazelVersion failed: %v", err)
	}
	if got != "development version" {
		t.Errorf("detectBazelVersion = %q, want development version", got)
	}

	// Test case 3: Invalid output format
	bazelScriptInvalid := filepath.Join(tmpDir, "bazel_invalid")
	err = os.WriteFile(bazelScriptInvalid, []byte("#!/bin/sh\necho 'some random output'\n"), 0755)
	if err != nil {
		t.Fatalf("Failed to write test script: %v", err)
	}
	
	_, err = detectBazelVersion(bazelScriptInvalid)
	if err == nil {
		t.Errorf("detectBazelVersion expected error for invalid output, got nil")
	}
}

func TestOptionsValidate(t *testing.T) {
	tests := []struct {
		name    string
		opt     *Options
		wantErr bool
	}{
		{
			name: "Both BazelPath and HostBazelPath set",
			opt: &Options{
				BazelPath:     "/bin/bazel",
				HostBazelPath: "/usr/bin/bazel",
			},
			wantErr: true,
		},
		{
			name: "Both HostBazelPath and BazelVersion set",
			opt: &Options{
				HostBazelPath: "/usr/bin/bazel",
				BazelVersion:  "5.4.0",
			},
			wantErr: true,
		},
		{
			name: "Only HostBazelPath set (valid)",
			opt: &Options{
				HostBazelPath: "/usr/bin/bazel",
			},
			wantErr: false,
		},
	}
	
	for _, tc := range tests {
		tc := tc
		t.Run(tc.name, func(t *testing.T) {
			// Populate mandatory fields to avoid unrelated validation errors
			if tc.opt.ToolchainContainer == "" {
				tc.opt.ToolchainContainer = "dummy"
			}
			if tc.opt.ExecOS == "" {
				tc.opt.ExecOS = "linux"
			}
			if tc.opt.TargetOS == "" {
				tc.opt.TargetOS = "linux"
			}
			if tc.opt.OutputTarball == "" && tc.opt.OutputSourceRoot == "" {
				tc.opt.OutputTarball = "dummy.tar"
			}
			if tc.opt.PlatformParams == nil {
				tc.opt.PlatformParams = &PlatformToolchainsTemplateParams{}
			}
			tc.opt.GenCPPConfigs = true
			tc.opt.CppBazelCmd = "build"

			// If HostBazelPath is set and we expect no error, we must make sure it points to a valid file
			// because Validate() will try to detect version by running it!
			if tc.name == "Only HostBazelPath set (valid)" {
				tmpDir := t.TempDir()
				bazelScript := filepath.Join(tmpDir, "bazel")
				err := os.WriteFile(bazelScript, []byte("#!/bin/sh\necho 'bazel 5.4.0'\n"), 0755)
				if err != nil {
					t.Fatalf("Failed to write test script: %v", err)
				}
				tc.opt.HostBazelPath = bazelScript
			}

			err := tc.opt.Validate()
			if (err != nil) != tc.wantErr {
				t.Errorf("Validate() error = %v, wantErr %v", err, tc.wantErr)
			}
		})
	}
}

func TestIsBazelVersionLessThan(t *testing.T) {
	tests := []struct {
		name          string
		bazelVersion  string
		targetVersion string
		want          bool
	}{
		{
			name:          "Standard comparison - less",
			bazelVersion:  "5.0.0",
			targetVersion: "6.0.0",
			want:          true,
		},
		{
			name:          "Standard comparison - equal",
			bazelVersion:  "6.0.0",
			targetVersion: "6.0.0",
			want:          false,
		},
		{
			name:          "Standard comparison - greater",
			bazelVersion:  "7.0.0",
			targetVersion: "6.0.0",
			want:          false,
		},
		{
			name:          "Pre-release comparison",
			bazelVersion:  "7.0.0-pre.1",
			targetVersion: "7.0.0",
			want:          true,
		},
		{
			name:          "Unparseable version (panic recovery) - development version",
			bazelVersion:  "development version",
			targetVersion: "6.0.0",
			want:          false, // Should recover and assume newer (not less)
		},
		{
			name:          "Unparseable version (panic recovery) - custom build",
			bazelVersion:  "my-custom-build",
			targetVersion: "6.0.0",
			want:          false, // Should recover and assume newer (not less)
		},
	}

	for _, tc := range tests {
		tc := tc
		t.Run(tc.name, func(t *testing.T) {
			t.Parallel()
			got := isBazelVersionLessThan(tc.bazelVersion, tc.targetVersion)
			if got != tc.want {
				t.Errorf("isBazelVersionLessThan(%q, %q) = %v, want %v", tc.bazelVersion, tc.targetVersion, got, tc.want)
			}
		})
	}
}

func TestCppConfigTargetAndRepo(t *testing.T) {
	tests := []struct {
		name         string
		bazelVersion string
		wantTarget   string
		wantRepo     string
	}{
		{
			name:         "Bazel 7.4.0 (Legacy)",
			bazelVersion: "7.4.0",
			wantTarget:   "@local_config_cc//...",
			wantRepo:     "local_config_cc",
		},
		{
			name:         "Bazel 8.0.0 (Bzlmod)",
			bazelVersion: "8.0.0",
			wantTarget:   "@@rules_cc++cc_configure_extension+local_config_cc//...",
			wantRepo:     "rules_cc++cc_configure_extension+local_config_cc",
		},
		{
			name:         "Development version (assumed newer -> Bzlmod)",
			bazelVersion: "development version",
			wantTarget:   "@@rules_cc++cc_configure_extension+local_config_cc//...",
			wantRepo:     "rules_cc++cc_configure_extension+local_config_cc",
		},
	}

	for _, tc := range tests {
		tc := tc
		t.Run(tc.name, func(t *testing.T) {
			t.Parallel()
			gotTarget, gotRepo := cppConfigTargetAndRepo(tc.bazelVersion)
			if gotTarget != tc.wantTarget {
				t.Errorf("cppConfigTargetAndRepo(%q) gotTarget = %q, want %q", tc.bazelVersion, gotTarget, tc.wantTarget)
			}
			if gotRepo != tc.wantRepo {
				t.Errorf("cppConfigTargetAndRepo(%q) gotRepo = %q, want %q", tc.bazelVersion, gotRepo, tc.wantRepo)
			}
		})
	}
}

func TestGenConfigBuild(t *testing.T) {
	tests := []struct {
		name         string
		bazelVersion string
		wantParent   string
	}{
		{
			name:         "Bazel 6",
			bazelVersion: "6.4.0",
			wantParent:   "@local_config_platform//:host",
		},
		{
			name:         "Bazel 7",
			bazelVersion: "7.0.0",
			wantParent:   "@platforms//host",
		},
		{
			name:         "Bazel 8",
			bazelVersion: "8.0.0",
			wantParent:   "@platforms//host",
		},
		{
			name:         "Development version",
			bazelVersion: "development version",
			wantParent:   "@platforms//host",
		},
	}

	for _, tc := range tests {
		tc := tc
		t.Run(tc.name, func(t *testing.T) {
			opt := &Options{
				BazelVersion: tc.bazelVersion,
				PlatformParams: &PlatformToolchainsTemplateParams{
					ExecConstraints: []string{"@platforms//os:linux"},
				},
			}
			gotFile, err := genConfigBuild(opt)
			if err != nil {
				t.Fatalf("genConfigBuild failed: %v", err)
			}
			
			// Check if the generated content contains the expected parent platform
			content := string(gotFile.contents)
			expected := `parents = ["` + tc.wantParent + `"]`
			if !strings.Contains(content, expected) {
				t.Errorf("Expected content to contain %q, but got:\n%s", expected, content)
			}
		})
	}
}
