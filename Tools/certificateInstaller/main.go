package main

import (
	"bytes"
	"common"
	"fmt"
	"io/ioutil"
	"os"
	"os/exec"
	"path/filepath"
	"time"

	"github.com/jessevdk/go-flags"
	"howett.net/plist"
)

const (
	Version = "0.0.1"
	Update  = "init"
	CmdName = "certificateInstaller"
)

var (
	options Options
	parser  *flags.Parser
)

type Options struct {
	Version   bool   `short:"v" long:"version" description:"print current version"`
	Directory string `short:"d" long:"directory" description:"directory path of the certificate files" required:"true"`
}

type ProvisioningProfile struct {
	ExpirationDate time.Time
}

func init() {
	parser = flags.NewParser(&options, flags.Default)
	parser.Name = CmdName
	parser.Usage = "[Options] name"
}

func main() {
	common.ParseOrExit(*parser)

	if options.Version {
		fmt.Printf("%s: %s  %s\n", CmdName, Version, Update)
		os.Exit(0)
	}

	if _, err := os.Stat(options.Directory); os.IsNotExist(err) {
		common.ExitOnError(err.Error())
	}

	files, err := ioutil.ReadDir(options.Directory)
	if err != nil {
		common.ExitOnError(err.Error())
	}

	certs := filterProvisioningProfiles(files)
	for _, cert := range certs {
		certPath := filepath.Join(options.Directory, cert.Name())
		installProvisioningProfile(certPath)
	}
}

func filterProvisioningProfiles(files []os.FileInfo) []os.FileInfo {
	var filteredFiles []os.FileInfo
	for _, file := range files {
		if file.IsDir() {
			continue
		}
		if filepath.Ext(file.Name()) == ".mobileprovision" {
			filteredFiles = append(filteredFiles, file)
		}
	}
	return filteredFiles
}

func installProvisioningProfile(file string) {
	buildCommand := exec.Command("/usr/bin/security", "cms", "-D", "-i", file)
	var outb, errb bytes.Buffer
	buildCommand.Stdout = &outb
	buildCommand.Stderr = &errb

	err := buildCommand.Run()
	if err != nil {
		common.ExitOnError(err.Error())
	}

	var profile ProvisioningProfile
	_, err = plist.Unmarshal(outb.Bytes(), &profile)

	if err != nil {
		fmt.Println(err.Error())
		return
	}

	if profile.ExpirationDate.Before(time.Now()) {
		fmt.Println(file + " Expired")
		return
	}

	provisioningProfilesFolder := filepath.Join(os.Getenv("HOME"), "Library", "MobileDevice", "Provisioning Profiles")
	if _, err := os.Stat(provisioningProfilesFolder); os.IsNotExist(err) {
		common.CreateDirOrExit(provisioningProfilesFolder)
	}

	dst := filepath.Join(provisioningProfilesFolder, filepath.Base(file))
	err = common.CopyFile(file, dst)
	if err != nil {
		common.ExitOnError(err.Error())
	}
}
