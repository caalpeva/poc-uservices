package main

import "fmt"

func main() {
  var weekDays = make(map[string]int)
  weekDays["monday"] = 1
  weekDays["thuesday"] = 2
  weekDays["wednesday"] = 3
  weekDays["thursday"] = 4
  weekDays["friday"] = 5
  weekDays["saturday"] = 6
  weekDays["sunday"] = 0
  fmt.Println(weekDays)
  fmt.Println("My favourite day is", weekDays["saturday"])
}
