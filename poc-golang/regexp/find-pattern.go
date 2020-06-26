package main

import (
	"fmt"
	"regexp"
)

/*
La siguiente es una lista de caracteres comunes cuando se trabaja con expresiones regulares.
Caracter	Descripción
.	Cualquier caracter excepto un salto de línea.
*	Cero o más veces.
^	Inicio de una expresión.
$	Final de una expresión.
+	Una o mas veces.
?	Cero o mas veces.
[]	Cualquier caractér que se encuentre dentro de los corchetes.
{n}	n veces.
{n,}	n o mas veces.
{m,n}	Entre m y n veces.
*/

// https://regex101.com/

func main() {
	// expresion regular
	re := regexp.MustCompile("^[0-9]{4}(-[0-9]{2}){2} [0-9]{2}(:[0-9]{2}){2}$")
	// validar diferentes valores
	fmt.Println(re.MatchString("19-01-01 00:00:00"))
	fmt.Println(re.MatchString("2019-01-01 00:00:AA"))
	fmt.Println(re.MatchString("2019-01-01 00:00:00"))
	fmt.Println(re.MatchString("2020-20-01 00:00:00"))
}
