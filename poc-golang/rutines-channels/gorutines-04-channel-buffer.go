package main

import (
    "fmt"
    "time"
)

func leerArchivo1() string {
    time.Sleep(time.Second * 3)
    return "Datos del archivo1"
}

func leerArchivo2() string {
    time.Sleep(time.Second * 3)
    return "Datos del archivo2"
}

func main() {
  miCanal := make(chan string, 2)
  go func() {
    miCanal <- leerArchivo1()
  }()
  go func() {
    miCanal <- leerArchivo2()
    //close(miCanal)
    //miCanal <- "HOLA"
  }()


  /*
  time.Sleep(time.Second * 4)
  close(miCanal)
  for noticia := range miCanal {
    fmt.Println(noticia)
  }
  */

  fmt.Println(<-miCanal)
  fmt.Println(<-miCanal)
  fmt.Println("Continuar con la ejecución")
}
