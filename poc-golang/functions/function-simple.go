package main

import "fmt"

const PI = 3.14

func area(radio float64) float64 {
  return PI * radio * radio
}

func volumen(radio float64, altura float64) float64 {
  return area(radio) * altura
}

func main() {
  var radio = 3.0
  fmt.Println("El area del circulo cuyo radio es:", radio, area(radio))

  var altura = 75.0
  var radio2 = 30.0
  fmt.Println("El volumen del cubo para el radio y altura siguientes:", radio2, altura)
  fmt.Println("es =", volumen(radio2, altura))
}
