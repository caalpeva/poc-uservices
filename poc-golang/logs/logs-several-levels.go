package main

import (
    "errors"
    "log"
)

func main() {
    // go run logs-01.go > out-01.log 2>&1

    for i := 0; i <= 10; i++ {
      log.Printf("Error línea %v", i)
    }

    err := errors.New("Este es un error fatal de prueba")
    log.Fatal(err)
}
