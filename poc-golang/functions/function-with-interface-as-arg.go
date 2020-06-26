package main

import (
  "fmt"
  "reflect"
)

const PI = 3.14

type Figure interface {
  area() float64
  perimetro() float64
}

type Circle struct {
  Radio float64
}

type Square struct {
  Side float64
}

func (c *Circle) area() float64 {
  return PI * c.Radio * c.Radio
}

func (c *Circle) perimetro() float64 {
  return 2 * PI * c.Radio
}

func (s *Square) area() float64 {
  return s.Side * s.Side
}

func (s *Square) perimetro() float64 {
  return 4 * s.Side
}

func showFigure(f Figure) {
  fmt.Println("El area es:", reflect.TypeOf(f).Elem().Name(), f.area())
  fmt.Println("El perimetro es:", reflect.TypeOf(f).Elem().Name(), f.perimetro())
}

func main() {
  circle := Circle{Radio: 5}
  fmt.Println("El area del circulo es:", circle.area())
  showFigure(&circle)

  square := Square{Side: 5}
  showFigure(&square)
}
