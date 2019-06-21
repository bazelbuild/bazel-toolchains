package metadata

// PackageMetadata is the YAML entry for a single software package.
type PackageMetadata struct {
	// Name is the name of the software package.
	Name string `yaml:"name"`
	// Version is the version string of the software package.
	Version string `yaml:"version"`
}

// PackagesMetadata is the collection of software package metadata read from
// the input CSV file to be serialized into a YAML file.
type PackagesMetadata struct {
	// Packages is the list of software package entries read from the input
	// CSV file.
	Packages []PackageMetadata `yaml:"packages"`
}
