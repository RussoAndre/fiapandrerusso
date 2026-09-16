package main

import (
	"encoding/json"
	"log"
	"net/http"
	"os"
	"sync"
	"time"
)

type HealthResponse struct {
	Status  string `json:"status"`
	Service string `json:"service"`
}

type Flag struct {
	Key     string `json:"key"`
	Enabled bool   `json:"enabled"`
}

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
	if err := json.NewEncoder(w).Encode(HealthResponse{Status: "ok", Service: "flag"}); err != nil {
		http.Error(w, "encoding error", http.StatusInternalServerError)
	}
}

func listFlagsHandler(w http.ResponseWriter, r *http.Request) {
	mu.RLock()
	defer mu.RUnlock()

	list := make([]Flag, 0, len(flags))
	for _, f := range flags {
		list = append(list, f)
	}
	w.Header().Set("Content-Type", "application/json")
	if err := json.NewEncoder(w).Encode(list); err != nil {
		http.Error(w, "encoding error", http.StatusInternalServerError)
	}
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
	if err := json.NewEncoder(w).Encode(f); err != nil {
		http.Error(w, "encoding error", http.StatusInternalServerError)
	}
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

	srv := &http.Server{
		Addr:         ":" + port,
		Handler:      mux,
		ReadTimeout:  10 * time.Second,
		WriteTimeout: 10 * time.Second,
		IdleTimeout:  60 * time.Second,
	}

	log.Printf("flag service listening on :%s", port)
	if err := srv.ListenAndServe(); err != nil {
		log.Fatalf("server error: %v", err)
	}
}
