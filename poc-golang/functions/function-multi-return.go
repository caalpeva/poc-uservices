package main

import "fmt"

const PI = 3.14

func circulo(radio float64) (area float64, perimetro float64) {
  area = PI * radio * radio
  perimetro = 2 * PI * radio
  //return area, perimetro
  return
}

func main() {
  var radio = 3.0
  area, perimetro := circulo(radio)
  fmt.Println("El area del circulo cuyo radio es:", radio, area)
  fmt.Println("El perimetro del circulo cuyo radio es:", radio, perimetro)
}
