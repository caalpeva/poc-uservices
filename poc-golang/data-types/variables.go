package main

import "fmt"

func main() {
  var valor int
  var valor2 float32
  var valor3 bool
  var valor4 string

  fmt.Println("Valores por defecto", valor, valor2, valor3, valor4)

  var nombre, apellidos string = "Pepito", "Grillo"
  fmt.Println(nombre, apellidos)

  var (
    nombre2 string = "Perico"
    edad int = 55
    pensionado bool = false
  )

  fmt.Println(nombre2, edad, pensionado)
}
