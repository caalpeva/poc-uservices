package main

import (
    "net/http"
)

// curl -is http://localhost:8000

func Home(w http.ResponseWriter, r *http.Request) {
    w.Header().Set("Content-Type", "text/html")
    w.Write([]byte("<H1>Hola Mundo</H1>"))
}

func main() {
    http.HandleFunc("/", Home)
    http.ListenAndServe(":8000", nil)
}
