package main

import (
	"encoding/json"
	"fmt"
	"log"
)

type Country struct {
	Name       string   `json:"name"`
	Capital    string   `json:"capital"`
	Population int      `json:"population,omitempty"`
	Languages  []string `json:"languages"`
}

func main() {
	country := Country{
		Name:      "Canada",
		Capital:   "Ottawa",
		Languages: []string{"English", "French"},
	}
	fmt.Printf("%v\n", country)

	jsonData, err := json.Marshal(country)
	if err != nil {
		log.Fatal(err)
	}

	fmt.Println(string(jsonData))
}
