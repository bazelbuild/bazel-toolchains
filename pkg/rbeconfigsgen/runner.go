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

import "fmt"

type runner interface {
	// execCmd runs the given command in runner env and returns the output with whitespace
	// trimmed from the edges.
	execCmd(args ...string) (string, error)

	// copyTo copies the local file at 'src' to 'dst' in the runner env.
	copyTo(src, dst string) error

	// copyFrom extracts the file at 'src' from runner and copies it to the path 'dst' locally.
	copyFrom(src, dst string) error

	cleanup()

    // getEnv gets the shell environment values from the runner
	getEnv() (map[string]string, error)

	setAdditionalEnv(map[string]string)

	getAdditionalEnv() map[string]string

	getWorkdir() string

	setWorkdir(string)
}

func convertAdditionalEnv(r runner) []string {
	addEnv := []string{}
	for k, v := range r.getAdditionalEnv() {
		addEnv = append(addEnv, fmt.Sprintf("%s=%s", k, v))
	}
	return addEnv
}