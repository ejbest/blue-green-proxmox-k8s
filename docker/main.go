package main

import (
	"context"
	"encoding/json"
	"fmt"
	"log"
	"net/http"
	"os"
	"os/exec"
	"os/signal"
	"sync"
	"time"
)

type Data struct {
	ResponseType string `json:"response_type"`
	Text         string `json:"text"`
}

type Response struct {
	ResponseType string `json:"response_type"`
	Text         string `json:"text"`
}

type Pipeline struct {
	WebUrl string `json:"web_url"`
}

func trigger(w http.ResponseWriter, r *http.Request, script string) {

	out, _ := exec.Command("./trigger_scripts/" + script).Output()
	var pipeline Pipeline
	json.Unmarshal(out, &pipeline)

	response := Response{
		ResponseType: "in_channel",
		Text:         fmt.Sprintf("Success\nPipeline url: %s", pipeline.WebUrl),
	}

	jsonResponse, err := json.Marshal(response)
	if err != nil {
		log.Printf("Could not marshal response: %v", err)
		http.Error(w, "Internal server error", http.StatusInternalServerError)
		return
	}

	w.Header().Set("Content-Type", "application/json")
	w.Write(jsonResponse)
	wait := &sync.WaitGroup{}
	wait.Add(1)

	go func(wg *sync.WaitGroup) {
		defer wg.Done()

		response := Response{
			ResponseType: "in_channel",
		}

		out, err := exec.Command("./trigger_scripts/" + script).Output()
		if err != nil {
			log.Printf("failed to send trigger: %s", err.Error())
			response.Text = fmt.Sprintf("Failed to marshal response object:%s", err.Error())
			return
		} else {
			var pipeline Pipeline
			json.Unmarshal(out, &pipeline)
			response.Text = fmt.Sprintf("Success\nPipeline url: %s", pipeline.WebUrl)
			log.Print(response)
			return
		}

	}(wait)

	wait.Wait()
}

func main() {
	routes := map[string]string{
		// Green vm
		"/green-deploy":  "green-ci-deploy.sh",
		"/green-destroy": "green-ci-destroy.sh",
		"/blue-deploy":   "blue-ci-deploy.sh",
		"/blue-destroy":  "blue-ci-destroy.sh",
	}

	for route, script := range routes {
		route := route
		script := script
		http.HandleFunc(route, func(w http.ResponseWriter, r *http.Request) {
			trigger(w, r, script)
		})
	}

	http.HandleFunc("/", func(w http.ResponseWriter, r *http.Request) {
		if auth(w, r) {
			fmt.Fprintf(w, "If you see this page, server is successfully installed and working.")
		}
	})
	fmt.Printf("Starting server on :2045\n")
	server := &http.Server{Addr: ":2045"}
	go func() {
		if err := server.ListenAndServe(); err != nil && err != http.ErrServerClosed {
			log.Fatalf("ListenAndServe(): %s", err)
		}
	}()

	// Wait for interrupt signal to gracefully shutdown the server
	quit := make(chan os.Signal, 1)
	signal.Notify(quit, os.Interrupt)
	<-quit
	fmt.Println("Shutting down server...")

	ctx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
	defer cancel()

	if err := server.Shutdown(ctx); err != nil {
		log.Fatalf("Server forced to shutdown: %s", err)
	}

	fmt.Println("Server exiting")
}
