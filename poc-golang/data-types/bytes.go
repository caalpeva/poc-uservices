package main

import "fmt"

func main() {
    text := "holA"
    fmt.Println(len(text))
    fmt.Println(text[0])
    fmt.Printf("%q\n", text[0])
    fmt.Printf("%b\n", text[0])
    fmt.Println("**********")
    
    fmt.Println(text[3])
    fmt.Printf("%q\n", text[3])
    fmt.Printf("%b\n", text[3])
    fmt.Println("**********")

    nihao := "你好"
    fmt.Println(len(nihao))
}
