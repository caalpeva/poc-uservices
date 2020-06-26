package main

import "fmt"

func ecoDeLaMontana(mensaje string, iteraciones uint) {
    if iteraciones > 1 {
        ecoDeLaMontana(mensaje, iteraciones-1)
    }
    fmt.Println(mensaje, iteraciones)
}

func main() {
    ecoDeLaMontana("yodelayheehoo", 5)
}
