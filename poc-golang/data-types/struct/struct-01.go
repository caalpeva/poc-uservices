package main

import "fmt"

type Country struct {
  name string
  capital string
  language string
  population int
}

func main() {
  var emptyCountry Country
  emptyCountry.language = "Unknown"
  fmt.Printf("%+v\n", emptyCountry)

  country := Country {
    name: "Ireland",
    capital: "Dublind",
    language: "English",
    population: 4857000,
  }
  fmt.Printf("%+v\n", country)
  fmt.Println("Country:", country.name)
  fmt.Println("Capital:", country.capital)
  fmt.Println("Country:", country.language)
  fmt.Println("Country:", country.population)
  fmt.Println("********** copy by value")

  // Copia por valor
  countryCopy := country
  country.population = 100000
  fmt.Printf("%+v\n", country)
  fmt.Printf("%+v\n", countryCopy)

  // Copia por referencia
  countryCopy2 := &country
  country.population = 200000
  fmt.Println("********** copy by reference")
  fmt.Printf("%+v\n", country)
  fmt.Printf("%+v\n", *countryCopy2)

  country2 := new(Country)
  country2.name = "Colombia"
  country2.capital = "Bogotá"
  country2.language = "Español"
  country2.population = 49e6
  fmt.Printf("%+v\n", country2)
  fmt.Println("********** copy by reference")

  // Copia por referencia a partir de un new
  country3 := country2
  country2.population = 50e6
  fmt.Printf("%+v\n", country2)
  fmt.Printf("%+v\n", country3)
}
