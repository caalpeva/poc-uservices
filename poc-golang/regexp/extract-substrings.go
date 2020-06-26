package main

import (
	"fmt"
	"io/ioutil"
	"log"
	"regexp"
)

func main() {

	// en donde vamos a capturar los nombres
	var nombres = make([]string, 3)

	// cargar contenido del html
	datosComoBytes, err := ioutil.ReadFile("lista.html")
	if err != nil {
		log.Fatal(err)
	}

	// preparar la expresion regular
	expReg := regexp.MustCompile(`(<span class="nombre">)([^<]+)(</span>)`)

	// ejecutar la busqueda de los indices
	todosLosIndices := expReg.FindAllSubmatchIndex(datosComoBytes, -1)

	// recorrer los resultados y capturar el nombre
	for _, loc := range todosLosIndices {
		fmt.Println(loc[4])
		fmt.Println(loc[5])
		fmt.Println(string(datosComoBytes[loc[4]:loc[5]]))
		nombres = append(nombres, string(datosComoBytes[loc[4]:loc[5]]))
	}

	// imprimir los nombres
	fmt.Println(nombres)
}
