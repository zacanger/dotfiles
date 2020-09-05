//usr/local/bin/go run $0 $@; exit $?

package main

import (
	"bytes"
	"encoding/csv"
	"encoding/json"
	"fmt"
	"io/ioutil"
	"log"
	"os"
	"path/filepath"
	"strconv"
	"strings"
)

func main() {
	path := os.Args[1]
	fileBytes, newFilePath := ReadCSV(path)
	SaveFile(fileBytes, newFilePath)
	fmt.Println("Saved to", newFilePath)
}

func ReadCSV(path string) ([]byte, string) {
	csvFile, err := os.Open(path)

	if err != nil {
		log.Fatal("No file found")
	}
	defer csvFile.Close()

	reader := csv.NewReader(csvFile)
	content, _ := reader.ReadAll()

	if len(content) < 1 {
		log.Fatal("Something went wrong!")
	}

	headersArr := make([]string, 0)
	for _, headE := range content[0] {
		headersArr = append(headersArr, headE)
	}

	// Remove the header row
	content = content[1:]

	var buffer bytes.Buffer
	buffer.WriteString("[")
	for i, d := range content {
		buffer.WriteString("{")
		for j, y := range d {
			buffer.WriteString(`"` + headersArr[j] + `":`)
			_, fErr := strconv.ParseFloat(y, 32)
			_, bErr := strconv.ParseBool(y)
			if fErr == nil {
				buffer.WriteString(y)
			} else if bErr == nil {
				buffer.WriteString(strings.ToLower(y))
			} else {
				buffer.WriteString((`"` + y + `"`))
			}
			// end of property
			if j < len(d)-1 {
				buffer.WriteString(",")
			}

		}
		// end of object of the array
		buffer.WriteString("}")
		if i < len(content)-1 {
			buffer.WriteString(",")
		}
	}

	buffer.WriteString(`]`)
	rawMessage := json.RawMessage(buffer.String())
	x, _ := json.MarshalIndent(rawMessage, "", "  ")
	newFileName := filepath.Base(path)
	newFileName = newFileName[0:len(newFileName)-len(filepath.Ext(newFileName))] + ".json"
	r := filepath.Dir(path)
	return x, filepath.Join(r, newFileName)
}

func SaveFile(myFile []byte, path string) {
	if err := ioutil.WriteFile(path, myFile, os.FileMode(0644)); err != nil {
		panic(err)
	}
}
