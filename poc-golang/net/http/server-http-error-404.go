package main

import (
    "net/http"
)

// curl -is http://localhost:8000
// curl -is http://localhost:8000/prueba

func Home(w http.ResponseWriter, r *http.Request) {
    if r.URL.Path != "/" {
        http.NotFound(w, r)
        return
    }

    w.Write([]byte("Hola Mundo"))
}

func main() {
    http.HandleFunc("/", Home)
    http.ListenAndServe(":8000", nil)
}
