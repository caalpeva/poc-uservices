package main

import (
	"fmt"
	"time"
)

func main() {
	var i int = 0

	fmt.Println("initializing program")
	//loop:
	for {
		for j := 0; j < 3; j++ {
			fmt.Println("j: ", j)
			fmt.Println("BREAK")
			break
			//break loop
		}

		if i >= 5 {
			fmt.Println("BREAK")
			break
		}

		time.Sleep(time.Second * 1)
		i++
		fmt.Println("i:", i)
	}

	fmt.Println("Exiting program")
}
