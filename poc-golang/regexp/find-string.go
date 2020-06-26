package main

import (
	"fmt"
	"log"
	"regexp"
)

func main() {
	pattern := "el perro"
	text := "vuelve el perro arrepentido"
	matched, err := regexp.MatchString(pattern, text)
	if err != nil {
		log.Fatal(err)
	}
	fmt.Println(matched)
}
