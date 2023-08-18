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
