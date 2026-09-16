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

type Event struct {
	FlagKey   string    `json:"flag_key"`
	UserID    string    `json:"user_id"`
	Value     bool      `json:"value"`
	Timestamp time.Time `json:"timestamp"`
}

type Summary struct {
	FlagKey    string `json:"flag_key"`
	TrueCount  int    `json:"true_count"`
	FalseCount int    `json:"false_count"`
}

var (
	mu     sync.RWMutex
	events []Event
)

func healthHandler(w http.ResponseWriter, r *http.Request) {
	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(HealthResponse{Status: "ok", Service: "analytics"})
}

func trackHandler(w http.ResponseWriter, r *http.Request) {
	if r.Method != http.MethodPost {
		http.Error(w, "method not allowed", http.StatusMethodNotAllowed)
		return
	}
	var e Event
	if err := json.NewDecoder(r.Body).Decode(&e); err != nil {
		http.Error(w, "invalid request body", http.StatusBadRequest)
		return
	}
	if e.FlagKey == "" || e.UserID == "" {
		http.Error(w, "flag_key and user_id are required", http.StatusBadRequest)
		return
	}
	e.Timestamp = time.Now().UTC()

	mu.Lock()
	events = append(events, e)
	mu.Unlock()

	w.WriteHeader(http.StatusCreated)
}

func summaryHandler(w http.ResponseWriter, r *http.Request) {
	mu.RLock()
	defer mu.RUnlock()

	counts := map[string]*Summary{}
	for _, e := range events {
		if _, ok := counts[e.FlagKey]; !ok {
			counts[e.FlagKey] = &Summary{FlagKey: e.FlagKey}
		}
		if e.Value {
			counts[e.FlagKey].TrueCount++
		} else {
			counts[e.FlagKey].FalseCount++
		}
	}

	result := make([]Summary, 0, len(counts))
	for _, s := range counts {
		result = append(result, *s)
	}

	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(result)
}

func main() {
	port := os.Getenv("PORT")
	if port == "" {
		port = "8084"
	}

	mux := http.NewServeMux()
	mux.HandleFunc("/health", healthHandler)
	mux.HandleFunc("/analytics/track", trackHandler)
	mux.HandleFunc("/analytics/summary", summaryHandler)

	log.Printf("analytics service listening on :%s", port)
	if err := http.ListenAndServe(":"+port, mux); err != nil {
		log.Fatalf("server error: %v", err)
	}
}
