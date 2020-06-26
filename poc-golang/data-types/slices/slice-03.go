package main

import "fmt"

func main() {
    figuras := []string{"circulo", "cuadrado", "triangulo", "rombo", "trapecio", "heptagono"}
    var figuras2 = make([]string, len(figuras))
    fmt.Println(figuras)
    copy(figuras2, figuras)
    fmt.Println(figuras2)
    figuras = append(figuras[:1], figuras[2:]...)
    fmt.Println("**************")
    fmt.Println(figuras)
    fmt.Println(figuras2)
}
