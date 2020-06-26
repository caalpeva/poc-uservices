package main

import (
	"fmt"
	"io"
	"log"
	"os"
)

func main() {
	source, err := os.Open("source.txt")
	if err != nil {
		log.Fatal(err)
	}
	defer source.Close() // Cierra el archivo origen al terminar el programa

	destination, err := os.OpenFile("destination.txt", os.O_RDWR|os.O_CREATE, 0666)
	if err != nil {
		log.Fatal(err)
	}
	defer destination.Close() // Cierra el archivo destino al terminar el programa

	result, err := io.Copy(destination, source)
	if err != nil {
		log.Fatal(err)
	}

	fmt.Println(result)
}
