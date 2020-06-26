package main

import (
	"fmt"
	"io/ioutil"
	"log"
	"net/http"
)

func main() {
	res, err := http.Get("http://www.google.es")
	if err != nil {
		log.Fatal(err)
	}

	fmt.Println(res.Proto, res.Status)
	fmt.Println("Content-Type:", res.Header.Get("Content-Type"))
	//fmt.Println("Content-Length:", res.ContentLength)

	defer res.Body.Close()
	body, err := ioutil.ReadAll(res.Body)
	if err != nil {
		log.Fatal(err)
	}
	fmt.Printf("%s", body)
}
