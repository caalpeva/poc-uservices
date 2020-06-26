package main

import (
	"fmt"
	"time"
)

func main() {
	timer := time.Tick(3 * time.Second)
	for horaActual := range timer {
		fmt.Println("La hora es", horaActual)
	}
}
