package main

import (
	"fmt"
	"io/ioutil"
	"log"
	"regexp"
)

func main() {

	datosComoBytes, err := ioutil.ReadFile("lista.html")
	if err != nil {
		log.Fatal(err)
	}

	coincidenciasRe := regexp.MustCompile(`<li>(.+)</li>`)
	htmlRe := regexp.MustCompile(`<[^>]+>`)
	nombres := coincidenciasRe.FindAllString(string(datosComoBytes), -1)

	for _, nombre := range nombres {
		nombreSinHtml := htmlRe.ReplaceAllString(nombre, "")
		fmt.Println(nombreSinHtml)
	}

}
