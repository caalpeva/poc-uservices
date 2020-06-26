package main

import (
	"fmt"
	"time"
)

func main() {
	ahora := time.Now()
	fmt.Println("Fecha en este momento:")
	fmt.Println(ahora)
	fmt.Println("Dentro de una semana:")
	proxSemana := ahora.Add(time.Hour * 24 * 7)
	fmt.Println(proxSemana)

	fmt.Println("Equals?", ahora.Equal(proxSemana))
	fmt.Println("Before?", ahora.Before(proxSemana))
	fmt.Println("After?", ahora.After(proxSemana))
}
