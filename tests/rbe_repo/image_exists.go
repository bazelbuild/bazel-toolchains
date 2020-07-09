// Binary image_exists checks if a image on a remote repository by fetching
// and examining its manifest but not downloading any of the layer blobs.
package main

import (
	"flag"
	"fmt"
	"log"

	"github.com/google/go-containerregistry/pkg/name"
	"github.com/google/go-containerregistry/pkg/v1/remote"
)

// ArrayStringFlags are defined for string flags that may have multiple values.
type ArrayStringFlags []string

// Returns the concatenated string representation of the array of flags.
func (f *ArrayStringFlags) String() string {
	return fmt.Sprintf("%v", *f)
}

// Get returns an empty interface that may be type-asserted to the underlying
// value of type bool, string, etc.
func (f *ArrayStringFlags) Get() interface{} {
	return ""
}

// Set appends value the array of flags.
func (f *ArrayStringFlags) Set(value string) error {
	*f = append(*f, value)
	return nil
}

func checkImage(image string) error {
	ref, err := name.ParseReference(image)
	if err != nil {
		return fmt.Errorf("failed to parse image name %q: %v", image, err)
	}
	img, err := remote.Image(ref)
	if err != nil {
		return fmt.Errorf("failed to reference remote image %q: %v", image, err)
	}

	d, err := img.Digest()
	if err != nil {
		return fmt.Errorf("failed to determine digest of image %q: %v", image, err)
	}
	layers, err := img.Layers()
	if err != nil {
		return fmt.Errorf("failed to get layers in image %q: %v", image, err)
	}
	for i, l := range layers {
		d, err := l.Digest()
		if err != nil {
			return fmt.Errorf("failed to get digest of layer %d in image %q: %v", i, image, err)
		}
		s, err := l.Size()
		if err != nil {
			return fmt.Errorf("failed to get size of layer %d with digest %v in image %q: %v", i, d, image, err)
		}
		log.Printf("Image %s: Layer [%d] digest:%v size:%d OK.", image, i, d, s)
	}
	log.Printf("Successfully validated image %q exists: digest %v with %d layers.", image, d, len(layers))
	return nil
}

func main() {
	images := ArrayStringFlags{}
	flag.Var(&images, "image", "One or more fully qualified remote image name to check.")
	flag.Parse()

	if len(images) == 0 {
		log.Fatalf("At least one image must be specified using --image for validation.")
	}

	errors := 0
	for _, i := range images {
		if err := checkImage(i); err != nil {
			log.Printf("ERROR: %q: %v", i, err)
			errors++
		}
	}

	if errors > 0 {
		log.Fatalf("Validation failed for %d images.", errors)
	}
	log.Printf("Successfully validated %d images.", len(images))
}
