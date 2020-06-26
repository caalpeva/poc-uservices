package main

import "fmt"

func main() {
  var color = "red"
  fmt.Println(color, &color)

  vehiculo1 := "rojo"
  fmt.Println("El vehiculo1 es", vehiculo1, &vehiculo1)

  vehiculo2 := vehiculo1
  fmt.Println("El vehiculo2 es", vehiculo2, &vehiculo2)

  vehiculo3 := &vehiculo1
  fmt.Println("El vehiculo3 es", *vehiculo3, vehiculo3)

  vehiculo1 = "gris"

  fmt.Println("El vehiculo1 es", vehiculo1, &vehiculo1)
  fmt.Println("El vehiculo2 es", vehiculo2, &vehiculo2)
  fmt.Println("El vehiculo3 es", *vehiculo3, vehiculo3)
}
