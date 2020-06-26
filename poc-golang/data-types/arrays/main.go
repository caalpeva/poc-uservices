package main

//import "fmt"

import (
  "fmt"
  "reflect"
  "strconv"
)

func sumar(a int, b int) int {
  return a + b
}

func main() {
  var b bool = true
  //var age = 33
  var age int = 33
  var PI float32 = 3.14
  var text string = "Pepito grillo"
  var arreglo [4]string
  arreglo[0] = "Uno"
  arreglo[1] = "Dos"
  arreglo[2] = "Tres"
  arreglo[3] = "Cuatro"
  //arreglo[4] = "Cinco"
  var mayorDeEdad string = "true"

  fmt.Println("Hola mundo!")
  fmt.Println(sumar(6, 5))
  fmt.Println(b)
  fmt.Println(age)
  fmt.Println(PI)
  fmt.Println(text)
  fmt.Println(arreglo)

  fmt.Println(reflect.TypeOf(age))
  fmt.Println(reflect.TypeOf(PI))
  fmt.Println(reflect.TypeOf(text))
  fmt.Println(reflect.TypeOf(arreglo))

  boolVal, _ := strconv.ParseBool(mayorDeEdad)
  fmt.Println(boolVal, reflect.TypeOf(boolVal))
  boolString := strconv.FormatBool(b)
  fmt.Println(boolString, reflect.TypeOf(boolString))

  var numero int = 8
  fmt.Println("Concatena con numero " + strconv.Itoa(numero))
}
