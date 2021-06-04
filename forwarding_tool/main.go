package main

import (
	"io"
	"net"
)

func main() {
	server, err := net.Listen("tcp", ":50443")
	if err != nil {
		return
	}
	for {
		client, err := server.Accept()
		if err == nil {
			go handleClientRequest(client)
		}
	}
}

func handleClientRequest(client net.Conn) {
	defer client.Close()

	remote, err := net.Dial("tcp", "127.0.0.1:50443")
	if err != nil {
		return
	}
	defer remote.Close()

	go io.Copy(remote, client)
	io.Copy(client, remote)
}
