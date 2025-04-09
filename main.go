package main

import (
	"fmt"
	"os"

	"github.com/go-git/go-git/v5"
)

var (
	repo = "https://github.com/tailscale/tailscale.git"
)

func main() {

	// Check if the directory already exists
	if _, err := os.Stat("./repo"); os.IsNotExist(err) {
		// Directory does not exist, clone the repository
		clone()
	} else {
		// Directory exists, pull the latest changes
		pull()
	}
}

func clone() {
	// Clone the given repository to the given directory
	fmt.Printf("git clone %s", repo)

	_, err := git.PlainClone("./repo", false, &git.CloneOptions{
		URL:      repo,
		Progress: os.Stdout,
	})

	if err != nil {
		fmt.Println("Error cloning repository:", err)
		return
	}
}

func pull() {
	r, err := git.PlainOpen("./repo")
	if err != nil {
		fmt.Println("Error opening repository:", err)
		return
	}
	w, err := r.Worktree()
	if err != nil {
		fmt.Println("Error getting worktree:", err)
		return
	}
	err = w.Pull(&git.PullOptions{
		RemoteName: "origin",
		Progress:   os.Stdout,
	})
	if err != nil {
		fmt.Println("Error pulling changes:", err)
		return
	}
	fmt.Println("Successfully pulled changes")
}
