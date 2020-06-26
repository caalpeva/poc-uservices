package main

import (
    "net/http"
)

// curl -is http://localhost:8000

func Home(w http.ResponseWriter, r *http.Request) {
    w.Header().Set("Content-Type", "application/json; charset=utf-8")
    w.Write([]byte(`{"mensaje":"Hola Mundo"}`))
}

func main() {
    http.HandleFunc("/", Home)
    http.ListenAndServe(":8000", nil)
}
