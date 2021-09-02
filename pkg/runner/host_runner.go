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

import (
	"fmt"
	"io/ioutil"
	"log"
	"os"
	"os/exec"
	"strings"
)

// hostRunner implements interface Runner
// hostRunner allows subsequently running
// arbitrary commands directly on the host.
type hostRunner struct {
	// global workdir is initial workdir
	globalWorkdir string
	// workdir is the working directory to use to run commands.
	workdir string

	// deleteWorkdir controls if global working directory is removed during cleanup. True by default
	deleteWorkdir bool

	// additionalEnv is the environment variables to set when executing commands
	additionalEnv map[string]string
}

// NewHostRunner creates a new Runner which executes commands directly on the host where rbe_configs_gen runs.
// deleteWorkdir determines if the Cleanup function of the hostRunner will remove temporary directory
func NewHostRunner(deleteWorkdir bool) (*hostRunner, error) {

	workdir, err := ioutil.TempDir("", "host_runner_")
	if err != nil {
		return nil, fmt.Errorf("failed to create a temporary local directory for host Runner: %w", err)
	}

	return &hostRunner{
		globalWorkdir: workdir,
		workdir: workdir,
		deleteWorkdir:  deleteWorkdir,
	}, nil
}

// ExecCmd runs the given command and returns the output with whitespace
// trimmed from the edges.
func (r *hostRunner) ExecCmd(cmd string, args ...string) (string, error) {
	log.Printf("Running: %s", strings.Join(append([]string{cmd}, args...), " "))
	c := exec.Command(cmd, args...)
	c.Env = append(os.Environ(), convertAdditionalEnv(r)...)
	//log.Printf("Running env: %v", c.Env)
	c.Dir = r.workdir
	o, err := c.CombinedOutput()
	if err != nil {
		log.Printf("Output: %s", o)
		return "", err
	}
	return strings.TrimSpace(string(o)), err
}

// Cleanup deletes runner temporary files if deleteWorkdir was true when the hostRunner was created.
func (r *hostRunner) Cleanup() {
	if !r.deleteWorkdir {
		log.Printf("Not deleting workdir %v because the Cleanup option was set to false.", r.globalWorkdir)
		return
	}

	if err := os.RemoveAll(r.globalWorkdir); err != nil {
		log.Printf("Failed to delete %v", r.globalWorkdir)
	}
}

// CopyTo copies the local file at 'src' to 'dst' on the host
// CopyTo works the same way as CopyFrom for the host runner
func (r *hostRunner) CopyTo(src, dst string) error {
	if _, err := runCmd("cp", src, dst); err != nil {
		return err
	}
	return nil
}

// CopyFrom copies the local file at 'src' to 'dst' on the host
// CopyFrom works the same way as CopyTo for the host runner
func (r *hostRunner) CopyFrom(src, dst string) error {
	if _, err := runCmd("cp", src, dst); err != nil {
		return err
	}
	return nil
}

// GetEnv gets the shell environment values from the host.
// Env values set or changed by running commands inside the runner aren't
// captured by the return value of this function.
// The return value of this function is a map from env keys to their values.
func (r *hostRunner) GetEnv() (map[string]string, error) {
	result := make(map[string]string)
	for _, s := range os.Environ() {
		s = strings.TrimSpace(s)
		if len(s) == 0 {
			continue
		}
		keyVal := strings.SplitN(s, "=", 2)
		key := ""
		val := ""
		if len(keyVal) == 2 {
			key, val = keyVal[0], keyVal[1]
		} else if len(keyVal) == 1 {
			// Maybe something like 'KEY=' was specified. We assume value is blank.
			key = keyVal[0]
		}
		if len(key) == 0 {
			continue
		}
		result[key] = val
	}
	return result, nil
}

func (r *hostRunner) GetWorkdir() string {
	return r.workdir
}

func (r *hostRunner) SetWorkdir(wd string) error {
	if !strings.HasPrefix(wd, r.globalWorkdir) {
		return fmt.Errorf("refusing to set working directory %s: host runner allows workdirs only in parent temporary directory %s", wd, r.globalWorkdir)
	}
	r.workdir = wd
	return nil
}

func (r *hostRunner) GetAdditionalEnv() map[string]string {
	return r.additionalEnv
}

func (r *hostRunner) SetAdditionalEnv(env map[string]string) {
	r.additionalEnv = env
}
