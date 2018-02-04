package main

import (
	"log"
	"github.com/jonas-p/go-shp"
	"github.com/kellydunn/golang-geo"
	"fmt"
)

func main() {
	shape, err := shp.Open("wojewodztwa/województwa.shp")
	if err != nil { log.Fatal(err) } 
	defer shape.Close()
	toSearch := geo.NewPoint(52.422462, 16.932402)
	for shape.Next() {
		n, p := shape.Shape()
		points := p.(*shp.Polygon).Points

		fields := shape.Fields()
		pointMap := make([]*geo.Point, len(points))
		for index, point := range points {
			pointMap[index] = geo.NewPoint(point.X, point.Y)
		}
		polygon := geo.NewPolygon(pointMap)
		contains := polygon.Contains(toSearch)
		fmt.Println(contains)

		for k, f := range fields {
			val := shape.ReadAttribute(n, k)
			fmt.Printf("\t%v: %v\n", f, val)
		}
	}
}