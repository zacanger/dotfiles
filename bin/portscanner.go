//usr/bin/env go run $0 $@; exit $?

package main

import (
	"flag"
	"fmt"
	"net"
	"runtime"
	"strconv"
)

var ip = flag.String("host", "127.0.0.1", "target ip address")

type Scanner struct {
	ip string
}

func (scanner *Scanner) scan(signal chan int, port int) {
	_, err := net.Dial("tcp", scanner.ip+":"+strconv.Itoa(port))
	if err != nil {
		signal <- 0
		return
	}
	signal <- 0
	fmt.Println("open:", port)
}

func main() {
	flag.Parse()
	runtime.GOMAXPROCS(runtime.NumCPU())
	scanner := Scanner{*ip}
	ch := make(chan int, 65535)

	for i := 0; i <= 65535; i++ {
		go scanner.scan(ch, i)
	}

	for i := 0; i <= 65535; i++ {
		<-ch
	}
}
