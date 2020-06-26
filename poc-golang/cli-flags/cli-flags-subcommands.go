package main

import (
    "flag"
    "fmt"
    "os"
    "strings"
)

func main() {

    // personalizar la ayuda
    flag.Usage = func() {
        documentacion := `Las opciones disponibles son
mayus Convierte el texto a mayúsculas
minus Convierte el texto a minúsculas`
        fmt.Fprintf(os.Stderr, "%s\n", documentacion)
    }

    // crear 2 subcomandos
    subCmdMayus := flag.NewFlagSet("mayus", flag.ExitOnError)
    subCmdMinus := flag.NewFlagSet("minus", flag.ExitOnError)

    // si la lista de argumentos no es la suficiente imprimir la ayuda
    if len(os.Args) == 1 {
        flag.Usage()
        return
    }

    // determinar que subcomando ejecutar
    switch os.Args[1] {
    case "mayus":
        // extraer el argumento -s y convertirlo en mayusculas
        s := subCmdMayus.String("s", "", "Introduzca el texto a convertir en mayúsculas")
        subCmdMayus.Parse(os.Args[2:])
        fmt.Println(strings.ToUpper(*s))
    case "minus":
        // extraer el argumento -s y convertirlo en minusculas
        s := subCmdMinus.String("s", "", "Introduzca el texto a convertir en minúsculas")
        subCmdMinus.Parse(os.Args[2:])
        fmt.Println(strings.ToLower(*s))
    default:
        // mostrar la documentacion
        flag.Usage()
    }
}
