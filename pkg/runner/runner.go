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

// Package runner provides generic Runner interface
// and its implementations
package runner

import "fmt"

// Runner interface represents runner which allows to execute commands in
// (possibly) isolated environment
type Runner interface {

	// ExecCmd executes the given command within the runner environment
	// and returns the output with whitespace trimmed from the edges.
	ExecCmd(cmd string, args ...string) (string, error)

	// CopyTo copies the local file to the runner env.
	CopyTo(src, dst string) error

	// CopyFrom copies the file from runner to the local path.
	CopyFrom(src, dst string) error

	// Cleanup removes runner environment (temporary files, containers)
	// after toolchain configuration is generated.
	Cleanup()

    // GetEnv returns default variables from runner environment,
    // which are supposed to be available during remote execution.
	GetEnv() (map[string]string, error)

	// SetAdditionalEnv adds auxiliary variables needed during toolchain config generation.
	SetAdditionalEnv(map[string]string)

	// GetAdditionalEnv returns variables previously added with SetAdditionalEnv.
	GetAdditionalEnv() map[string]string

	// SetWorkdir sets new working directory for command execution inside the runner
	SetWorkdir(string) error

	// GetWorkdir returns current workdir used for command execution.
	GetWorkdir() string

}

// convertAdditionalEnv returns list of additional env vars in a format
// suitable for passing to os/exec.Cmd
func convertAdditionalEnv(r Runner) []string {
	addEnv := make([]string, 0)
	for k, v := range r.GetAdditionalEnv() {
		addEnv = append(addEnv, fmt.Sprintf("%s=%s", k, v))
	}
	return addEnv
}