package main

import (
  "fmt"
  "io/ioutil"
)

func main() {
  text, err := ioutil.ReadFile("archivo.txt")
  if err != nil {
    fmt.Println(err)
    return
  }

  fmt.Println(text)
}
