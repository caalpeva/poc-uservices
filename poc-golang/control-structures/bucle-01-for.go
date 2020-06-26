package main

import "fmt"

func main() {
	var repeticiones int

	fmt.Println("Cuantas veces replica la montaña:")
	fmt.Scanln(&repeticiones)
	for i := 1; i <= repeticiones; i++ {
		fmt.Println("yodelayheehoo", i)
	}
}
