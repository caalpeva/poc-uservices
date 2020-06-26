package main

import (
	"log"
	"os"
)

func main() {
	// touch erasable-file.txt
	err := os.Remove("erasable-file.txt")
	if err != nil {
		log.Fatal(err)
	}
}
