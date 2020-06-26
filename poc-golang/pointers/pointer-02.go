package main

import "fmt"

func scaleToFoot(altura float32) float32 {
    altura = altura * 3.28
    return altura
}

func modifyToFoot(altura *float32) float32 {
    *altura = *altura * 3.28
    return *altura
}

func main() {
  var altura float32 = 1.70

  fmt.Println("La altura es:", altura, "mts")
  fmt.Println("La altura es:", scaleToFoot(altura), " pies")
  fmt.Println("La variable altura no se modifica:", altura, "mts")

  fmt.Println("La altura es:", altura, "mts")
  fmt.Println("La altura es:", modifyToFoot(&altura), " pies")
  fmt.Println("La variable altura se modifica:", altura, "mts")
}
