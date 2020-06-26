package main

import (
    "fmt"
    "strings"
)

func main() {
    title := "La Guerra de las Galaxias"
    fmt.Println(strings.ToUpper(title))
    fmt.Println(strings.ToLower(title))

    if strings.Contains(title, "Galaxias") {
        fmt.Println("Galaxias es substring")
    }

    text := "Esto es una prueba"
    if posicion := strings.Index(text, "prueba") ; posicion != -1 {
        fmt.Println("La posicion de prueba es", posicion)
    }

    fmt.Println(strings.TrimSpace("  remover espacio en ambos lados "))
    fmt.Println(strings.TrimLeft("¿Cuantos años tiene usted?", "¿"))
    fmt.Println(strings.TrimRight("¿Cuantos años tiene usted?", "?"))
}
