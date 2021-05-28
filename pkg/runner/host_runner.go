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

// NewHostRunner creates a new Runner which executes commands directly in host environment. deleteWorkdir
// determines if the Cleanup function on the hostRunner will remove temporary directory
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

// execCmd runs the given command and returns the output with whitespace
// trimmed from the edges.
func (r *hostRunner) ExecCmd(args ...string) (string, error) {
	log.Printf("Running: %s", strings.Join(args, " "))
	c := exec.Command(args[0], args[1:]...)
	c.Env = append(os.Environ(), convertAdditionalEnv(r)...)
	c.Dir = r.workdir
	o, err := c.CombinedOutput()
	if err != nil {
		log.Printf("Output: %s", o)
		return "", err
	}
	return strings.TrimSpace(string(o)), err
}

// cleanup stops the running container if stopContainer was true when the hostRunner was created.
func (r *hostRunner) Cleanup() {
	if !r.deleteWorkdir {
		log.Printf("Not deleting workdir %v because the Cleanup option was set to false.", r.globalWorkdir)
		return
	}

	if err := os.RemoveAll(r.globalWorkdir); err != nil {
		log.Printf("Failed to delete %v", r.globalWorkdir)
	}
}

// copyTo copies the local file at 'src' to the container where 'dst' is the path inside
// the container. d.workdir has no impact on this function.
func (r *hostRunner) CopyTo(src, dst string) error {
	if _, err := runCmd("cp", src, dst); err != nil {
		return err
	}
	return nil
}

// copyFrom extracts the file at 'src' from inside the container and copies it to the path
// 'dst' locally. d.workdir has no impact on this function.
func (r *hostRunner) CopyFrom(src, dst string) error {
	if _, err := runCmd("cp", src, dst); err != nil {
		return err
	}
	return nil
}

// getEnv gets the shell environment values from the toolchain container as determined by the
// image config. Env value set or changed by running commands after starting the container aren't
// captured by the return value of this function.
// The return value of this function is a map from env keys to their values. If the image config,
// specifies the same env key multiple times, later values supercede earlier ones.
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

func (r *hostRunner) SetWorkdir(wd string) {
	r.workdir = wd
}

func (r *hostRunner) GetAdditionalEnv() map[string]string {
	return r.additionalEnv
}

func (r *hostRunner) SetAdditionalEnv(env map[string]string) {
	r.additionalEnv = env
}
