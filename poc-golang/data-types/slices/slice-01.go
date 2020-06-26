package main

import "fmt"

func main() {
  var marcasDeCoches = make([]string, 2)
  marcasDeCoches[0] = "Seat"
  marcasDeCoches[1] = "Citroen"
  fmt.Println(marcasDeCoches)
  nuevoSlice := append(marcasDeCoches, "Renault", "Toyota")
  //fmt.Println(marcasDeCoches)
  fmt.Println(nuevoSlice)
}
