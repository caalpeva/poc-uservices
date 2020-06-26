package main

import (
  "fmt"
)

func venderCerveza(edad int, cantidad int) (int, error) {
  if edad < 18 {
    err := fmt.Errorf("No se puede vender cerveza a menores")
    return 0, err
  }

  return cantidad, nil
}

func manejarResultado(edad int, cantidad1 int) {
    cantidad, err := venderCerveza(edad, cantidad1)
    if err != nil {
      fmt.Println(err)
    } else {
      fmt.Println("Se vendieron", cantidad, "cervezas")
    }
}

func main() {
    manejarResultado(15, 6)
    manejarResultado(21, 24)
}
