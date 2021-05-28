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
package runner

import "fmt"

type Runner interface {
	// execCmd runs the given command in Runner env and returns the output with whitespace
	// trimmed from the edges.
	ExecCmd(args ...string) (string, error)

	// copyTo copies the local file at 'src' to 'dst' in the Runner env.
	CopyTo(src, dst string) error

	// copyFrom extracts the file at 'src' from Runner and copies it to the path 'dst' locally.
	CopyFrom(src, dst string) error

	Cleanup()

    // getEnv gets the shell environment values from the Runner
	GetEnv() (map[string]string, error)

	SetAdditionalEnv(map[string]string)

	GetAdditionalEnv() map[string]string

	GetWorkdir() string

	SetWorkdir(string)
}

func convertAdditionalEnv(r Runner) []string {
	addEnv := []string{}
	for k, v := range r.GetAdditionalEnv() {
		addEnv = append(addEnv, fmt.Sprintf("%s=%s", k, v))
	}
	return addEnv
}