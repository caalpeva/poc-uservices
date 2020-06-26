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
	jsonData := `{"name":"Canada","capital":"Ottawa","population":3000000,"languages":["English","French"]}`
	fmt.Println(jsonData)

	country := Country{}
	err := json.Unmarshal([]byte(jsonData), &country)
	if err != nil {
		log.Fatal(err)
	}

	fmt.Printf("%v\n", country)
}
