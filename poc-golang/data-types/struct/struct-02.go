package main

import "fmt"

type Country struct {
  name string
  capital string
  language string
  population int
}

type Auto struct {
    Marca    string
    Submarca string
    Modelo   int
    Color    string
}

func main() {
  auto1 := Auto{
    Marca:    "Toyota",
    Submarca: "Prius",
    Modelo:   2015,
    Color:    "blanco",
  }
  auto2 := Auto{
      Marca:    "Toyota",
      Submarca: "Corolla",
      Modelo:   2017,
      Color:    "cafe",
  }
  auto3 := Auto{
      Marca:    "Toyota",
      Submarca: "Prius",
      Modelo:   2015,
      Color:    "blanco",
  }

  if auto1 != auto2 {
    fmt.Println("Auto1 y Auto2 son diferentes")
  }

  if auto1 == auto3 {
    fmt.Println("Auto1 y Auto3 son iguales")
  }

  /*
  country := Country {
    name: "Ireland",
    capital: "Dublind",
    language: "English",
    population: 4857000,
  }

  if country != auto1 {
    fmt.Println("Auto1 y Country son diferentes")
  }
  */
}
