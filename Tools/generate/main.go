package main

import (
	"common"
	"fmt"
	"io/ioutil"
	"os"
	"os/exec"

	"github.com/jessevdk/go-flags"
)

const (
	Version = "0.0.1"
	Update  = "init"
	CmdName = "generate"
)

var (
	options Options
	parser  *flags.Parser
)

type Options struct {
	Version          bool   `short:"v" long:"version" description:"print current version"`
	OrganizationName string `long:"organizationName" description:"add organizationName" required:"true" default:"doom"`

	Framework   string `short:"f" long:"framework" description:"add framework"`
	Integration string `short:"i" long:"integration" description:"add integration"`
	Output      string `short:"o" long:"output" description:"output path"`
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

	if len(options.Framework) > 0 {
		createModule(options.Framework)
	} else if len(options.Integration) > 0 {
		createIntegration(options.Integration)
	} else {
		common.ExitOnErrorWriteHelp(*parser, "")
	}
}

func createModule(name string) {
	var dirPath string
	if len(options.Output) > 0 {
		dirPath = options.Output + "/"
	} else {
		dirPath = "../../Projects/"
	}
	dirPath += name

	common.CreateDirOrExit(dirPath)
	common.CreateDirOrExit(dirPath + "/Sources")
	common.CreateFileOrExit(fmt.Sprintf("%v/Sources/%v.swift", dirPath, name))
	common.CreateDirOrExit(dirPath + "/Tests")
	common.CreateFileOrExit(fmt.Sprintf("%v/Tests/%vTests.swift", dirPath, name))
	codeString := fmt.Sprintf(`import ProjectDescription
import ProjectDescriptionHelpers

// MARK: - Project

let project = Project.common(
	name: "%v",
	product: .framework,
	organizationName: "%v",
	resources: nil
)
	`, name, options.OrganizationName)

	err := ioutil.WriteFile(dirPath+"/Project.swift", []byte(codeString), 0666)
	if err != nil {
		common.ExitOnError(err.Error())
	}
}

func createIntegration(name string) {
	var dirPath string
	if len(options.Output) > 0 {
		dirPath = options.Output + "/"
	} else {
		dirPath = "../../Integrations/"
	}

	dirPath += name + "Integration"
	common.CreateDirOrExit(dirPath)

	codeString := fmt.Sprintf(`import ProjectDescription
import ProjectDescriptionHelpers

// MARK: - Project

let project = Project.common(
	name: "%vIntegration",
	product: .framework,
	organizationName: "%v",
	sources: nil,
	resources: nil,
	testSources: nil,
	dependencies: [
		.package(product: "%vContainer"),
	],
	packages: [
		.local(path: "./%vContainer"),
	]
)
		`, name, options.OrganizationName, name, name)

	err := ioutil.WriteFile(dirPath+"/Project.swift", []byte(codeString), 0666)
	if err != nil {
		common.ExitOnError(err.Error())
	}

	containerPath := fmt.Sprintf("%v/%vContainner", dirPath, name)
	common.CreateDirOrExit(containerPath)
	err = os.Chdir(containerPath)
	if err != nil {
		common.ExitOnError(err.Error())
	}
	err = exec.Command("swift", "package", "init").Run()
	if err != nil {
		common.ExitOnError(err.Error())
	}
}
