package main

import "fmt"

var empleado = "Gustavo Mitos"
var var1 = "Este es el nivel 1"

func sueldo() {
  sueldo := 40000
  fmt.Println(empleado, sueldo)
}

func main() {
  valor := 20
  valor2 := 3.14
  valor3 := true
  valor4 := "Esto es una prueba"

  fmt.Println("Valores por defecto", valor, valor2, valor3, valor4)
  sueldo()

  var var2 = "Este es el nivel 2"
  {
    var var3 = "Este es el nivel 3"
    fmt.Println(var3)
  }

  fmt.Println(var1)
  fmt.Println(var2)
  //fmt.Println(var3)
}
