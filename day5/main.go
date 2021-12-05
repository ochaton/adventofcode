package main

import (
	"bufio"
	"fmt"
	"log"
	"math"
	"os"
	"strconv"
	"strings"
)

type Line struct {
	X1 int
	Y1 int
	X2 int
	Y2 int
}

type Field [][]int

func main() {
	lines := readFile("input.txt")
	f := buildField(lines)

	more2 := 0
	for x := 0; x < len(f); x++ {
		for y := 0; y < len(f[x]); y++ {
			if f[x][y] >= 2 {
				more2++
			}
			// fmt.Print(f[x][y])
		}
		// fmt.Println()
	}

	fmt.Println(more2)
}

func buildField(lines []Line) (f Field) {
	vh := []Line{}
	dg := []Line{}
	var mx, my int
	for _, l := range lines {
		if l.X1 == l.X2 || l.Y1 == l.Y2 {
			vh = append(vh, l)
		} else if max(l.X2, l.X1)-min(l.X2, l.X1) == max(l.Y1, l.Y2)-min(l.Y1, l.Y2) {
			dg = append(dg, l)
		}

		if l.X1 > mx {
			mx = l.X1
		}
		if l.X2 > mx {
			mx = l.X2
		}
		if l.Y1 > my {
			my = l.Y1
		}
		if l.Y2 > my {
			my = l.Y2
		}
	}

	f = make(Field, my+1)
	for y := 0; y <= my; y++ {
		f[y] = make([]int, mx+1)
	}

	// vertical and horizontal
	for _, l := range vh {
		for x := min(l.X1, l.X2); x <= max(l.X1, l.X2); x++ {
			for y := min(l.Y1, l.Y2); y <= max(l.Y1, l.Y2); y++ {
				f[y][x] = f[y][x] + 1
			}
		}
	}

	// diagonal
	for _, l := range dg {
		maxx, minx := max(l.X1, l.X2), min(l.X1, l.X2)
		for p := 0; p <= maxx-minx; p++ {
			y := l.Y1 + p*(l.Y2-l.Y1)/int(math.Abs(float64(l.Y2)-float64(l.Y1)))
			x := l.X1 + p*(l.X2-l.X1)/int(math.Abs(float64(l.X2)-float64(l.X1)))
			// fmt.Printf("setting {%d:%d}->{%d:%d} {%d:%d}\n",
			// 	l.X1, l.Y1, l.X2, l.Y2,
			// 	y, x)
			f[y][x] = f[y][x] + 1
		}
	}

	return
}

func min(a, b int) int {
	if a < b {
		return a
	} else {
		return b
	}
}

func max(a, b int) int {
	if a > b {
		return a
	} else {
		return b
	}
}

func readFile(f string) (lines []Line) {
	file, err := os.Open(f)
	if err != nil {
		log.Fatalln(err)
	}
	defer file.Close()
	s := bufio.NewScanner(file)

	for s.Scan() {
		line := s.Text()
		ps := strings.Split(line, " -> ")
		if len(ps) != 2 {
			log.Fatalf("split failed: %s", line)
		}

		cords := make([]int, 4)
		for i, p := range ps {
			cs := strings.Split(p, ",")
			if len(cs) != 2 {
				log.Fatalf("split , failed: %s", p)
			}

			if cords[2*i], err = strconv.Atoi(cs[0]); err != nil {
				log.Fatalf("%s -> %s", cs[0], err)
			}
			if cords[2*i+1], err = strconv.Atoi(cs[1]); err != nil {
				log.Fatalf("%s -> %s", cs[0], err)
			}
		}

		lines = append(lines, Line{
			cords[0],
			cords[1],
			cords[2],
			cords[3],
		})
	}

	if err := s.Err(); err != nil {
		log.Fatalln(err)
	}

	return
}
