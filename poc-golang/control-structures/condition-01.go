package main

import "fmt"

func main() {
  var edad uint8
  fmt.Println("Cual es tu edad?")
  fmt.Scanln(&edad)
  if edad >= 18 {
    fmt.Println("Eres mayor de edad")
  } else {
    fmt.Println("Eres menor de edad")
  }
}
