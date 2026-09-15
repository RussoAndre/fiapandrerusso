package main

import (
	"encoding/json"
	"log"
	"net/http"
	"os"
	"sync"
)

// HealthResponse is returned by the health check endpoint.
type HealthResponse struct {
	Status  string `json:"status"`
	Service string `json:"service"`
}

// Flag represents a feature flag.
type Flag struct {
	Key     string `json:"key"`
	Enabled bool   `json:"enabled"`
}

// in-memory store for demo purposes.
var (
	mu    sync.RWMutex
	flags = map[string]Flag{
		"new-ui":      {Key: "new-ui", Enabled: true},
		"dark-mode":   {Key: "dark-mode", Enabled: false},
		"beta-search": {Key: "beta-search", Enabled: false},
	}
)

func healthHandler(w http.ResponseWriter, r *http.Request) {
	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(HealthResponse{Status: "ok", Service: "flag"})
}

func listFlagsHandler(w http.ResponseWriter, r *http.Request) {
	mu.RLock()
	defer mu.RUnlock()

	list := make([]Flag, 0, len(flags))
	for _, f := range flags {
		list = append(list, f)
	}
	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(list)
}

func getFlagHandler(w http.ResponseWriter, r *http.Request) {
	key := r.URL.Query().Get("key")
	if key == "" {
		http.Error(w, "key query param is required", http.StatusBadRequest)
		return
	}
	mu.RLock()
	f, ok := flags[key]
	mu.RUnlock()
	if !ok {
		http.Error(w, "flag not found", http.StatusNotFound)
		return
	}
	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(f)
}

func main() {
	port := os.Getenv("PORT")
	if port == "" {
		port = "8081"
	}

	mux := http.NewServeMux()
	mux.HandleFunc("/health", healthHandler)
	mux.HandleFunc("/flags", listFlagsHandler)
	mux.HandleFunc("/flags/get", getFlagHandler)

	log.Printf("flag service listening on :%s", port)
	if err := http.ListenAndServe(":"+port, mux); err != nil {
		log.Fatalf("server error: %v", err)
	}
}
