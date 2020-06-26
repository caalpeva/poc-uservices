package main

import "fmt"

func main() {
  weekDays := map[string]string{
    "monday": "Lunes",
    "thuesday": "Martes",
    "wednesday": "Miercoles",
    "thursday": "Jueves",
    "friday": "Viernes",
    "saturday": "Sabado",
    "sunday": "Domingo",
  }

  fmt.Println(weekDays)
  delete(weekDays, "sunday")
  fmt.Println(weekDays)
}
