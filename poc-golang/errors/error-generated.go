package main

import (
  "fmt"
  "errors"
)

func main() {
  err := errors.New("error generado durante la ejecución")
  if err != nil {
      fmt.Println(err)
      // fmt.Println(err.Error())
    }
}
