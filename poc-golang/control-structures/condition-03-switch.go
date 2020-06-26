package main

import "fmt"

func main() {
    var juguete string
    fmt.Println("Elige persona, animal o cosa:")
    fmt.Scanln(&juguete)
    switch juguete {
    case "persona":
      fmt.Println("El objeto es una persona")
    case "cosa":
      fmt.Println("El objeto es una cosa")
    case "animal":
        fmt.Println("El objeto es un animal")
    default:
      fmt.Println("El objeto es otra categoria")
    }
}
