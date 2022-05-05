package common

import (
	"io"
	"log"
	"os"

	"github.com/jessevdk/go-flags"
)

func CreateDirOrExit(path string) {
	if _, err := os.Stat(path); !os.IsNotExist(err) {
		ExitOnError("create dir " + path + " error: " + err.Error())
	}
	err := os.Mkdir(path, os.ModePerm)
	if err != nil {
		ExitOnError("create dir " + path + " error: " + err.Error())
	}
}

func CreateFileOrExit(path string) {
	if _, err := os.Stat(path); !os.IsNotExist(err) {
		ExitOnError("create file " + path + " error: " + err.Error())
	}
	_, err := os.Create(path)
	if err != nil {
		ExitOnError("create file " + path + " error: " + err.Error())
	}
}

func CopyFile(src, dst string) (err error) {
	in, err := os.Open(src)
	if err != nil {
		return
	}
	defer in.Close()

	out, err := os.Create(dst)
	if err != nil {
		return
	}
	defer func() {
		if e := out.Close(); e != nil {
			err = e
		}
	}()

	_, err = io.Copy(out, in)
	if err != nil {
		return
	}

	err = out.Sync()
	if err != nil {
		return
	}

	si, err := os.Stat(src)
	if err != nil {
		return
	}
	err = os.Chmod(dst, si.Mode())
	if err != nil {
		return
	}

	return
}

func ParseOrExit(parser flags.Parser) []string {
	args, err := parser.Parse()
	if err != nil {
		if e, ok := err.(*flags.Error); ok && e.Type == flags.ErrHelp {
			os.Exit(0)
		} else {
			ExitOnErrorWriteHelp(parser, err.Error())
		}
	}

	return args
}

func ExitOnErrorWriteHelp(parser flags.Parser, msg string) {
	log.Fatalln(msg)
	parser.WriteHelp(os.Stderr)
	os.Exit(1)
}

func ExitOnError(msg string) {
	log.Fatalln(msg)
	os.Exit(1)
}
