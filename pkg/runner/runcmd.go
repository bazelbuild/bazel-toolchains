package runner

import (
	"fmt"
	"log"
	"os/exec"
	"strings"
)

// runCmd runs an arbitrary command in a shell, logs the exact command that was run and returns
// the generated stdout/stderr. If the command fails, the stdout/stderr is always logged.
func runCmd(cmd string, args ...string) (string, error) {
	cmdStr := fmt.Sprintf("'%s'", strings.Join(append([]string{cmd}, args...), " "))
	log.Printf("Running: %s", cmdStr)
	c := exec.Command(cmd, args...)
	o, err := c.CombinedOutput()
	if err != nil {
		log.Printf("Output: %s", o)
		return "", err
	}
	return string(o), nil
}

