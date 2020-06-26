package main

import (
	"fmt"
	"io/ioutil"
	"log"
)

func main() {
	arrayOfBytes, err := ioutil.ReadFile("employees.txt")
	if err != nil {
		log.Fatal(err)
	}

	fmt.Println(string(arrayOfBytes))
}
