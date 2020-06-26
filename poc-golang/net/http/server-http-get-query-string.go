package main

import (
    "fmt"
    "net/http"
)

//curl -is "http://localhost:8000?name=Pepito&apellido=Grillo" -X GET

func Home(w http.ResponseWriter, r *http.Request) {
    if r.URL.Path != "/" {
        http.NotFound(w, r)
        return
    }
    for k, v := range r.URL.Query() {
        fmt.Fprintf(w, "%s - %s\n", k, v)
    }
}

func main() {
    http.HandleFunc("/", Home)
    http.ListenAndServe(":8000", nil)
}
