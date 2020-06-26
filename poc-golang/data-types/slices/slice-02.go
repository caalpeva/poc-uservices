package main

import (
  "fmt"
  "reflect"
)

func main() {
    razasDePerros := []string{"labrador", "poodle", "doberman", "shitzu", "beagle"}
    fmt.Println(razasDePerros, reflect.TypeOf(razasDePerros))
    razasDePerros = append(razasDePerros[:2], razasDePerros[2+1:]...)
    fmt.Println(razasDePerros)
}
