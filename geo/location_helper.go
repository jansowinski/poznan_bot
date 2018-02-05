/*
Function wsg84ToPuwg92 rewritten from http://www.szymanski-net.eu/programy.html
As demanded by author, I'm leaving here his header:
Autor: Zbigniew Szymanski
E-mail: z.szymanski@szymanski-net.eu
Wersja: 1.1
Historia zmian:
    1.1 dodano przeksztalcenie odwrotne PUWG 1992 ->WGS84
    1.0 przeksztalcenie WGS84 -> PUWG 1992
Data modyfikacji: 2012-11-27
Uwagi: Oprogramowanie darmowe. Dozwolone jest wykorzystanie i modyfikacja
       niniejszego oprogramowania do wlasnych celow pod warunkiem
       pozostawienia wszystkich informacji z naglowka. W przypadku
       wykorzystania niniejszego oprogramowania we wszelkich projektach
       naukowo-badawczych, rozwojowych, wdrozeniowych i dydaktycznych prosze
       o zacytowanie nastepujacego artykulu:

       Zbigniew Szymanski, Stanislaw Jankowski, Jan Szczyrek,
       "Reconstruction of environment model by using radar vector field histograms.",
       Photonics Applications in Astronomy, Communications, Industry, and
       High-Energy Physics Experiments 2012, Proc. of SPIE Vol. 8454, pp. 845422 - 1-8,
       doi:10.1117/12.2001354

Literatura:
       Uriasz, J., “Wybrane odwzorowania kartograficzne”, Akademia Morska w Szczecinie,
       http://uriasz.am.szczecin.pl/naw_bezp/odwzorowania.html
*/

package main

import (
	"errors"
	"fmt"
	"github.com/jonas-p/go-shp"
	"github.com/kellydunn/golang-geo"
	"golang.org/x/text/encoding/charmap"
	"log"
	"math"
)

func main() {
	voievodship, err := shp.Open("data/wojewodztwa.shp")
	if err != nil {
		log.Fatal(err)
	}
	shire, err := shp.Open("data/powiaty.shp")
	if err != nil {
		log.Fatal(err)
	}
	fmt.Println(getName(voievodship, 52.420765, 16.942293))
	fmt.Println(getName(shire, 52.420765, 16.942293))
	defer voievodship.Close()
	defer shire.Close()
}

func getName(shape *shp.Reader, latInput float64, lngInput float64) string {
	lat, lng, err := wsg84ToPuwg92(latInput, lngInput)
	if err != nil {
		log.Fatal(err)
	}
	toSearch := geo.NewPoint(lng, lat)
	for shape.Next() {
		n, p := shape.Shape()
		points := p.(*shp.Polygon).Points

		pointMap := make([]*geo.Point, len(points))
		for index, point := range points {
			pointMap[index] = geo.NewPoint(point.X, point.Y)
		}
		polygon := geo.NewPolygon(pointMap)
		contains := polygon.Contains(toSearch)
		if contains {
			name := shape.ReadAttribute(n, 5)
			return DecodeWindows1250([]byte(name))
		}
	}
	return ""
}

func DecodeWindows1250(enc []byte) string {
	dec := charmap.Windows1250.NewDecoder()
	out, _ := dec.Bytes(enc)
	return string(out)
}

func wsg84ToPuwg92(B_stopnie float64, L_stopnie float64) (float64, float64, error) {
	var e float64 = 0.0818191910428
	var R0 float64 = 6367449.14577
	var Snorm float64 = 2.0E-6
	var xo float64 = 5760000.0
	var a0 float64 = 5765181.11148097
	var a1 float64 = 499800.81713800
	var a2 float64 = -63.81145283
	var a3 float64 = 0.83537915
	var a4 float64 = 0.13046891
	var a5 float64 = -0.00111138
	var a6 float64 = -0.00010504
	var L0_stopnie float64 = 19.0
	var m0 float64 = 0.9993
	var x0 float64 = -5300000.0
	var y0 float64 = 500000.0
	var Bmin float64 = 48.0 * math.Pi / 180.0
	var Bmax float64 = 56.0 * math.Pi / 180.0
	var dLmin float64 = -6.0 * math.Pi / 180.0
	var dLmax float64 = 6.0 * math.Pi / 180.0
	var B float64 = B_stopnie * math.Pi / 180.0
	var dL_stopnie float64 = L_stopnie - L0_stopnie
	var dL float64 = dL_stopnie * math.Pi / 180.0
	if (B < Bmin) || (B > Bmax) {
		err := errors.New("szerokosc geograficzna B poza zakresem")
		return 0.0, 0.0, err
	}
	if (dL < dLmin) || (dL > dLmax) {
		err := errors.New("dlugosc geograficzna L poza zakresem")
		return 0.0, 0.0, err
	}
	var U float64 = 1.0 - e*math.Sin(B)
	var V float64 = 1.0 + e*math.Sin(B)
	var K float64 = math.Pow((U / V), (e / 2.0))
	var C float64 = K * math.Tan(B/2.0+math.Pi/4.0)
	var fi float64 = 2.0*math.Atan(C) - math.Pi/2.0
	var d_lambda float64 = dL
	var p float64 = math.Sin(fi)
	var q float64 = math.Cos(fi) * math.Cos(d_lambda)
	var r float64 = 1.0 + math.Cos(fi)*math.Sin(d_lambda)
	var s float64 = 1.0 - math.Cos(fi)*math.Sin(d_lambda)
	var XMERC float64 = R0 * math.Atan(p/q)
	var YMERC float64 = 0.5 * R0 * math.Log(r/s)
	Z := complex((XMERC-xo)*Snorm, YMERC*Snorm)
	Zgk := complex(0.0, 0.0)
	a0complex := complex(a0, 0.0)
	a1complex := complex(a1, 0.0)
	a2complex := complex(a2, 0.0)
	a3complex := complex(a3, 0.0)
	a4complex := complex(a4, 0.0)
	a5complex := complex(a5, 0.0)
	a6complex := complex(a6, 0.0)
	Zgk = a0complex + Z*(a1complex+Z*(a2complex+Z*(a3complex+Z*(a4complex+Z*(a5complex+Z*a6complex)))))
	var Xgk float64 = real(Zgk)
	var Ygk float64 = imag(Zgk)
	return m0*Xgk + x0, m0*Ygk + y0, nil
}
