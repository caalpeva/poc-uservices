package main

import (
  "net/http"
  "log"
)

//curl -is http://localhost:8000 -H "Accept: application/json"
//curl -is http://localhost:8000 -H "Accept: application/xml"
//curl -is http://localhost:8000 -H "Accept: text/html"

func Home(w http.ResponseWriter, r *http.Request) {
    if r.URL.Path != "/" {
        http.NotFound(w, r)
        return
    }

    log.Printf("%v", r.Header.Get("Accept"))
    switch r.Header.Get("Accept") {
    case "application/json":
        w.Header().Set("Content-Type", "application/json; charset=utf-8")
        w.Write([]byte(`{"mensaje":"Hola Mundo"}`))
    case "application/xml":
        w.Header().Set("Content-Type", "application/xml; charset=utf-8")
        w.Write([]byte(`<?xml version="1.0" encoding="utf-8"?><Mensaje>Hola Mundo</Mensaje>`))
    default:
        w.Header().Set("Content-Type", "text/plain; charset=utf-8")
        w.Write([]byte("Hola Mundo"))
    }
}

func main() {
    http.HandleFunc("/", Home)
    http.ListenAndServe(":8000", nil)
}
