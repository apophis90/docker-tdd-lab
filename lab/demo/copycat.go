package main

import (
	"fmt"
	"io"
	"net"
	"os"
	"strconv"
)

const defaultPort = 2000
const protocol = "tcp"

func main() {
	port := os.Getenv("PORT")
	if len(port) == 0 {
		port = strconv.Itoa(defaultPort)
		fmt.Fprintf(os.Stderr, "Environment variable PORT not set, falling back to default port: %s\n", port)
	}

	server, err := net.Listen(protocol, ":"+port)

	if server == nil {
		fmt.Fprintf(os.Stderr, "Error starting Copycat: %v\n", err.Error())
		os.Exit(1)
	}

	fmt.Fprintf(os.Stdout, "Copycat listening at %v ...\n", server.Addr())

	connectionChannel := makeConnectionChannel(server)

	for {
		go handleConnection(<-connectionChannel)
	}
}

func createServer(protocol string, port int) (net.Listener, error) {
	return net.Listen(protocol, ":"+strconv.Itoa(port))
}

func makeConnectionChannel(listener net.Listener) chan net.Conn {
	channel := make(chan net.Conn)
	go func() {
		for {
			conn, err := listener.Accept()
			if conn == nil {
				fmt.Fprintf(os.Stderr, "Error accepting incoming connection %v\n", err.Error())
				continue
			}
			fmt.Fprintf(os.Stdout, "Accepted incoming connection from: %v\n", conn.RemoteAddr())
			channel <- conn
		}
	}()
	return channel
}

func handleConnection(conn net.Conn) {
	io.Copy(conn, conn)
	conn.Close()
}
