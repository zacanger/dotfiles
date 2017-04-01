//usr/bin/go run $0 $@ ; exit

package main

// from https://github.com/jessfraz/junk
import (
	"encoding/json"
	"fmt"
	"io"
	"log"
	"net/http"
	"os"
	"strings"
)

const (
	apiversion = "v2"
)

var (
	username = os.Getenv("DOCKER_HUB_USERNAME")
	password = os.Getenv("DOCKER_HUB_PASSWORD")
)

func main() {
	if username == "" || password == "" {
		log.Fatal("DOCKER_HUB_USERNAME and DOCKER_HUB_PASSWORD cannot be empty.")
	}

	// list all the repos
	repos, err := getRepos(username, fmt.Sprintf("https://hub.docker.com/%s/%s?page=1", apiversion, "repositories/"+username))
	if err != nil {
		log.Fatal(err)
	}

	token, err := login(username, password)
	if err != nil {
		log.Fatal(err)
	}

	for _, repo := range repos {
		// delete the repo
		log.Printf("deleting repo: %s/%s\n", repo.Namespace, repo.Name)
		if err := deleteRepo(repo.Namespace, repo.Name, token); err != nil {
			log.Fatal(err)
		}

		// recreate the repository as not an autobuild
		/*
			log.Printf("re-creating repo: %s/%s\n", repo.Namespace, repo.Name)
				if err := createRepo(repo.Namespace, repo.Name, token); err != nil {
					log.Fatal(err)
				}
		*/
	}
}

type repositoriesResponse struct {
	Count    int    `json:"count"`
	Next     string `json:"next"`
	Previous string `json:"previous"`
	Results  []repo `json:"results"`
}

type repo struct {
	User      string `json:"user"`
	Name      string `json:"name"`
	Namespace string `json:"namespace"`
}

func createRepo(namespace, repo, token string) error {
	resp, err := request("PUT", fmt.Sprintf("https://hub.docker.com/%s/repositories/%s/%s/", apiversion, namespace, repo), nil, token)
	if err != nil {
		return err
	}
	defer resp.Body.Close()

	if resp.StatusCode != http.StatusOK {
		return fmt.Errorf("status returned was not OK, was: %d", resp.StatusCode)
	}
	return nil
}

func deleteRepo(namespace, repo, token string) error {
	resp, err := request("DELETE", fmt.Sprintf("https://hub.docker.com/%s/repositories/%s/%s/", apiversion, namespace, repo), nil, token)
	if err != nil {
		return err
	}
	defer resp.Body.Close()

	if resp.StatusCode != http.StatusAccepted && resp.StatusCode != http.StatusOK {
		return fmt.Errorf("status returned was not OK or Accepted, was: %d", resp.StatusCode)
	}
	return nil
}

type info struct {
	Token string `json:"token"`
}

func login(username, password string) (string, error) {
	data := fmt.Sprintf(`{"username": %q, "password": %q}`, username, password)
	resp, err := request("POST", "https://hub.docker.com/v2/users/login/", strings.NewReader(data), "")
	if err != nil {
		return "", err
	}
	defer resp.Body.Close()

	var result info
	if err := json.NewDecoder(resp.Body).Decode(&result); err != nil {
		return "", fmt.Errorf("decoding json failed: %v", err)
	}

	return result.Token, nil
}

func getRepos(username, url string) ([]repo, error) {
	resp, err := request("GET", url, nil, "")
	if err != nil {
		return nil, err
	}
	defer resp.Body.Close()

	var result repositoriesResponse
	if err := json.NewDecoder(resp.Body).Decode(&result); err != nil {
		return nil, fmt.Errorf("decoding json failed: %v", err)
	}

	if result.Next != "" {
		// WTF Docker Hub is this a sick joke
		// Docker Hub will give back the url as: https://hub.docker.com/v2/repositories/jess/?page=1
		// But Docker Hub will not return results with the trailing slash on the username
		// I cannot even.
		result.Next = strings.Replace(result.Next, username+"/", username, 1)
		repos, err := getRepos(username, result.Next)
		if err != nil {
			return nil, err
		}
		return append(result.Results, repos...), nil
	}

	return result.Results, nil
}

func request(method, urlStr string, body io.Reader, token string) (*http.Response, error) {
	// create the client
	client := &http.Client{}

	// create the request
	req, err := http.NewRequest(method, urlStr, body)
	if err != nil {
		return nil, err
	}
	if token == "" {
		req.SetBasicAuth(username, password)
	} else {
		req.Header.Add("Authorization", "JWT "+token)
	}
	req.Header.Set("content-type", "application/json")

	return client.Do(req)
}
