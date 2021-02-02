package main

import (
	"flag"
	"log"

	"github.com/bazelbuild/bazel-toolchains/pkg/rbeconfigsgen"
)

var (
	// Mandatory input arguments.
	bazelVersion       = flag.String("bazel_version", "", "Bazel release version to generate configs for. E.g., 4.0.0.")
	toolchainContainer = flag.String("toolchain_container", "", "Repository path to toolchain image to generate configs for. E.g., l.gcr.io/google/rbe-ubuntu16-04:latest")
	execOS             = flag.String("exec_os", "", "The OS (linux|windows) of the toolchain container image a.k.a, the execution platform in Bazel.")
	targetOS           = flag.String("target_os", "", "The OS (linux|windows) artifacts built will target a.k.a, the target platform in Bazel.")

	// Arguments affecting how the generated configs are deployed by this tool.
	outputTarball    = flag.String("output_tarball", "", "(Optional) Path where a tarball with the generated configs will be dumped.")
	outputSrcRoot    = flag.String("output_src_root", "", "(Optional) Path to root directory of Bazel repository where generated configs should be copied to. Configs aren't copied if this is blank. Use '.' to specify the current directory.")
	outputConfigPath = flag.String("output_config_path", "", "(Optional) Path relative to what was specified to --output_src_root where configs will be extracted. Defaults to root if unspecified. --output_src_root is mandatory if this argument is specified.")

	// Optional input arguments that affect config generation.
	genCppConfigs  = flag.Bool("generate_cpp_configs", true, "(Optional) Generate C++ configs. Defaults to true.")
	genJavaConfigs = flag.Bool("generate_java_configs", true, "(Optional) Generate Java configs. Defaults to true.")

	// Other misc arguments.
	tempWorkDir = flag.String("temp_work_dir", "", "(Optional) Temporary directory to use to store intermediate files. Defaults to a temporary directory automatically allocated by the OS. The temporary working directory is deleted at the end unless --cleanup=false is specified.")
	cleanup     = flag.Bool("cleanup", true, "(Optional) Stop running container & delete intermediate files. Defaults to true. Set to false for debugging.")
)

func main() {
	flag.Parse()

	o := rbeconfigsgen.Options{
		BazelVersion:       *bazelVersion,
		ToolchainContainer: *toolchainContainer,
		ExecOS:             *execOS,
		TargetOS:           *targetOS,
		OutputTarball:      *outputTarball,
		OutputSourceRoot:   *outputSrcRoot,
		OutputConfigPath:   *outputConfigPath,
		GenCPPConfigs:      *genCppConfigs,
		GenJavaConfigs:     *genJavaConfigs,
		TempWorkDir:        *tempWorkDir,
		Cleanup:            *cleanup,
	}
	if err := o.ApplyDefaults(*execOS); err != nil {
		log.Fatalf("Failed to apply default options for OS name %q specified to --exec_os: %v", *execOS, err)
	}
	if err := o.Validate(); err != nil {
		log.Fatalf("Failed to validate command line arguments: %v", err)
	}
	if err := rbeconfigsgen.Run(o); err != nil {
		log.Fatalf("Config generation failed: %v", err)
	}
	log.Printf("Config generation was successful.")
}
