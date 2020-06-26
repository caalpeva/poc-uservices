package main

import (
	"fmt"
	"io/ioutil"
	"log"
	"net/http"
	"time"
)

func main() {
	client := &http.Client{
		//Timeout: 5 * time.Millisecond,
		Timeout: 5 * time.Second,
	}
	request, err := http.NewRequest("POST", "https://httpbin.org/post", nil)
	if err != nil {
		log.Fatal(err)
	}

	response, err := client.Do(request)
	if err != nil {
		log.Fatal(err)
	}

	fmt.Println(response.Proto, response.Status)
	fmt.Println("Content-Type:", response.Header.Get("Content-Type"))
	//fmt.Println("Content-Length:", res.ContentLength)

	defer response.Body.Close()
	body, err := ioutil.ReadAll(response.Body)
	if err != nil {
		log.Fatal(err)
	}
	fmt.Printf("%s", body)
}
