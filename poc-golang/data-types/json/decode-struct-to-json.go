package main

import (
	"encoding/json"
	"fmt"
	"log"
)

type Country struct {
	Name       string
	Capital    string
	Population int
	Languages  []string
}

func main() {
	country := Country{
		Name:       "Canada",
		Capital:    "Ottawa",
		Population: 3e6,
		Languages:  []string{"English", "French"},
	}
	fmt.Printf("%v\n", country)

	jsonData, err := json.Marshal(country)
	if err != nil {
		log.Fatal(err)
	}

	fmt.Println(string(jsonData))
}
