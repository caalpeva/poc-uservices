package main

import (
	"io/ioutil"
	"log"
)

func main() {
	arrayOfBytes := []byte("Hola Mundo!\n")
	err := ioutil.WriteFile("personal.txt", arrayOfBytes, 0644)
	// Permisos de lectura y escritura para el usuario,
	// permisos de lectura para el grupo y el resto de usuarios
	if err != nil {
		log.Fatal(err)
	}
}
