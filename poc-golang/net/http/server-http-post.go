package main

import (
	"fmt"
	"io/ioutil"
	"log"
	"net/http"
)

//curl http://localhost:8000/ -X POST -d "name=Raul&lastname=Jimenez"

func main() {
	http.HandleFunc("/", func(w http.ResponseWriter, r *http.Request) {
		if r.URL.Path != "/" {
			http.NotFound(w, r)
			return
		}

		content, err := ioutil.ReadAll(r.Body)
		if err != nil {
			log.Fatal(err)
		}
		fmt.Fprintf(w, "%s", content)
	})
	http.ListenAndServe(":8000", nil)
}
