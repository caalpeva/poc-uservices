package main

import (
	"fmt"
	"log"
	"time"
)

/*
Go soporta diferentes tipos de formatos para imprimir la fecha.
Formato	Salida
ANSIC	Wed Feb _2 10:15:06 2019
UnixDate	Wed Feb _2 10:15:06 MST 2019
RubyDate	Wed Feb 02 10:15:06 -0700 2019
RFC822	02 Feb 06 15:04 MST
RFC822Z	02 Feb 06 15:04 -0700
RFC850	Wedday, 02-Feb-06 10:15:06 MST
RFC1123	Wed, 02 Feb 2019 10:15:06 MST
RFC1123Z	Wed, 02 Feb 2019 10:15:06 -0700
RFC3339	2019-01-02T10:15:06Z07:00
RFC3339Nano	2019-01-02T10:15:06.999999999Z07:00
*/

func main() {

	fechaComoString := "2015-05-15T10:12:11+06:00"

	fecha, err := time.Parse(time.RFC3339, fechaComoString)

	if err != nil {
		log.Fatal(err)
	}

	fmt.Printf("El tipo es: %T \n", fecha)
	fmt.Printf("La fecha es: %v \n", fecha)

	fmt.Println("El año es:", fecha.Year())
	fmt.Println("El mes es:", fecha.Month())
	fmt.Println("El dia es:", fecha.Day())
	fmt.Println("La hora es:", fecha.Hour())
	fmt.Println("Los minutos son:", fecha.Minute())
	fmt.Println("Los segundos son:", fecha.Second())
}
