package main

import (
	"./geohelper"
  "fmt"
)

func main() {
  polska := geohelper.Create()
  fmt.Println(geohelper.GetInfo(polska, 53.697558, 17.569354))
}
