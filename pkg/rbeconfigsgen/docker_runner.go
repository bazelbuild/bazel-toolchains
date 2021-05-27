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
	"fmt"
	"log"
	"strings"
)

// workdir returns the root working directory to use inside the toolchain container for the given
// OS where the OS refers to the OS of the toolchain container.
func workdir(os string) string {
	switch os {
	case OSLinux:
		return "/workdir"
	case OSWindows:
		return "C:/workdir"
	}
	log.Fatalf("Invalid OS: %q", os)
	return ""
}

// dockerRunner implements interface runner
// dockerRunner allows starting a container for a given docker image and subsequently running
// arbitrary commands inside the container or extracting files from it.
// dockerRunner uses the docker client to spin up & interact with containers.
type dockerRunner struct {
	// Input arguments.
	// containerImage is the docker image to spin up as a running container. This could be a tagged
	// or floating reference to a docker image but in a format acceptable to the docker client.
	containerImage string
	// stopContainer determines if the running container will be deleted once we're done with it.
	stopContainer bool

	// Parameters that affect how commands are executed inside the running toolchain container.
	// These parameters can be changed between calls to the execCmd function.

	// workdir is the working directory to use to run commands inside the container.
	workdir string
	// additionalEnv is the environment variables to set when executing commands
	additionalEnv map[string]string

	// Populated by the runner.
	// dockerPath is the path to the docker client.
	dockerPath string
	// containerID is the ID of the running docker container.
	containerID string
	// resolvedImage is the container image referenced by its sha256 digest.
	resolvedImage string
}

// newDockerRunner creates a new running container of the given containerImage. stopContainer
// determines if the cleanup function on the dockerRunner will stop the running container when
// called.
func newDockerRunner(containerImage string, stopContainer bool, execOS string) (*dockerRunner, error) {
	if containerImage == "" {
		return nil, fmt.Errorf("container image was not specified")
	}
	d := &dockerRunner{
		containerImage: containerImage,
		stopContainer:  stopContainer,
		dockerPath:     "docker",
	}
	if _, err := runCmd(d.dockerPath, "pull", d.containerImage); err != nil {
		return nil, fmt.Errorf("docker was unable to pull the toolchain container image %q: %w", d.containerImage, err)
	}
	resolvedImage, err := runCmd(d.dockerPath, "inspect", "--format={{index .RepoDigests 0}}", d.containerImage)
	if err != nil {
		return nil, fmt.Errorf("failed to convert toolchain container image %q into a fully qualified image name by digest: %w", d.containerImage, err)
	}
	resolvedImage = strings.TrimSpace(resolvedImage)
	log.Printf("Resolved toolchain image %q to fully qualified reference %q.", d.containerImage, resolvedImage)
	d.resolvedImage = resolvedImage

	cid, err := runCmd(d.dockerPath, "create", "--rm", d.resolvedImage, "sleep", "infinity")
	if err != nil {
		return nil, fmt.Errorf("failed to create a container with the toolchain container image: %w", err)
	}
	cid = strings.TrimSpace(cid)
	if len(cid) != 64 {
		return nil, fmt.Errorf("container ID %q extracted from the stdout of the container create command had unexpected length, got %d, want 64", cid, len(cid))
	}
	d.containerID = cid
	log.Printf("Created container ID %v for toolchain container image %v.", d.containerID, d.resolvedImage)
	if _, err := runCmd(d.dockerPath, "start", d.containerID); err != nil {
		return nil, fmt.Errorf("failed to run the toolchain container: %w", err)
	}
	if _, err := d.execCmd("mkdir", workdir(execOS)); err != nil {
		d.cleanup()
		return nil, fmt.Errorf("failed to create workdir in toolchain container: %w", err)
	}
	d.setWorkdir(workdir(execOS))
	return d, nil
}

// execCmd runs the given command inside the docker container and returns the output with whitespace
// trimmed from the edges.
func (d *dockerRunner) execCmd(args ...string) (string, error) {
	a := []string{"exec"}
	if d.workdir != "" {
		a = append(a, "-w", d.workdir)
	}
	for _, e := range d.additionalEnv {
		a = append(a, "-e", e)
	}
	a = append(a, d.containerID)
	a = append(a, args...)
	o, err := runCmd(d.dockerPath, a...)
	return strings.TrimSpace(o), err
}

// cleanup stops the running container if stopContainer was true when the dockerRunner was created.
func (d *dockerRunner) cleanup() {
	if !d.stopContainer {
		log.Printf("Not stopping container %v of image %v because the Cleanup option was set to false.", d.containerID, d.resolvedImage)
		return
	}
	if _, err := runCmd(d.dockerPath, "stop", "-t", "0", d.containerID); err != nil {
		log.Printf("Failed to stop container %v of toolchain image %v but it's ok to ignore this error if config generation & extraction succeeded.", d.containerID, d.resolvedImage)
	}
}

// copyTo copies the local file at 'src' to the container where 'dst' is the path inside
// the container. d.workdir has no impact on this function.
func (d *dockerRunner) copyTo(src, dst string) error {
	if _, err := runCmd(d.dockerPath, "cp", src, fmt.Sprintf("%s:%s", d.containerID, dst)); err != nil {
		return err
	}
	return nil
}

// copyFrom extracts the file at 'src' from inside the container and copies it to the path
// 'dst' locally. d.workdir has no impact on this function.
func (d *dockerRunner) copyFrom(src, dst string) error {
	if _, err := runCmd(d.dockerPath, "cp", fmt.Sprintf("%s:%s", d.containerID, src), dst); err != nil {
		return err
	}
	return nil
}

// getEnv gets the shell environment values from the toolchain container as determined by the
// image config. Env value set or changed by running commands after starting the container aren't
// captured by the return value of this function.
// The return value of this function is a map from env keys to their values. If the image config,
// specifies the same env key multiple times, later values supercede earlier ones.
func (d *dockerRunner) getEnv() (map[string]string, error) {
	result := make(map[string]string)
	o, err := runCmd(d.dockerPath, "inspect", "-f", "{{range $i, $v := .Config.Env}}{{println $v}}{{end}}", d.resolvedImage)
	if err != nil {
		return nil, fmt.Errorf("failed to inspect the docker image to get environment variables: %w", err)
	}
	split := strings.Split(o, "\n")
	for _, s := range split {
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

func (d *dockerRunner) getWorkdir() string {
	return d.workdir
}

func (d *dockerRunner) setWorkdir(wd string) {
	d.workdir = wd
}

func (d *dockerRunner) getAdditionalEnv() map[string]string {
	return d.additionalEnv
}

func (d *dockerRunner) setAdditionalEnv(env map[string]string) {
	d.additionalEnv = env
}
