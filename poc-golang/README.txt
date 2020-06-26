# Show environment parameters
$ go version
$ go env

# Compile and create executable file
$ go build <filename>.go

# Compile and run (without executable file)
$ go run <filename>.go

# Test
$ go test             (Pruebas unitarias)
$ go test -bench = .  (Pruebas de rendimiento)
$ go test -cover      (Pruebas de cobertura)

# Reduce compilation dimension
$ GOOS=linux GOARCH=amd64 go build -ldflags="-s -w" <filename>.go // -ldflags="-s -w" (optional)
upx <executable-filename> // Ultimate Packer for eXecutables (https://upx.github.io/)

# Dep is a tool for managing dependencies for Go projects
$ go get -u github.com/golang/dep/cmd/dep
$ dep -help

# Generates checksum
$ sha1sum <filename>

https://apuntes.de/golang/#gsc.tab=0
https://golang.org/doc/effective_go.html

