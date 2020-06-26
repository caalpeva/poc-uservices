package main

import (
	"fmt"
	"io/ioutil"
	"log"
)

func main() {
	files, err := ioutil.ReadDir(".")
	if err != nil {
		log.Fatal(err)
	}

	for _, file := range files {
		fmt.Println("Name:", file.Name())
		fmt.Println("Size:", file.Size())
		fmt.Println("Mode:", file.Mode())
		fmt.Println("Last modificatoin:", file.ModTime())
		fmt.Println("Is directory?:", file.IsDir())
		fmt.Println("----------------------------------------")
	}
}
