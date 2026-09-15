package main

import (
	"encoding/json"
	"log"
	"net/http"
	"os"
)

// HealthResponse is returned by the health check endpoint.
type HealthResponse struct {
	Status  string `json:"status"`
	Service string `json:"service"`
}

// TargetRequest describes a user/context to evaluate targeting rules against.
type TargetRequest struct {
	UserID  string            `json:"user_id"`
	Context map[string]string `json:"context"`
}

// TargetResponse holds the targeting result.
type TargetResponse struct {
	UserID  string `json:"user_id"`
	Matched bool   `json:"matched"`
	Segment string `json:"segment"`
}

func healthHandler(w http.ResponseWriter, r *http.Request) {
	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(HealthResponse{Status: "ok", Service: "targeting"})
}

// evaluateHandler applies simple targeting rules (demo logic).
func evaluateHandler(w http.ResponseWriter, r *http.Request) {
	if r.Method != http.MethodPost {
		http.Error(w, "method not allowed", http.StatusMethodNotAllowed)
		return
	}
	var req TargetRequest
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		http.Error(w, "invalid request body", http.StatusBadRequest)
		return
	}
	if req.UserID == "" {
		http.Error(w, "user_id is required", http.StatusBadRequest)
		return
	}

	// Demo rule: users whose plan is "premium" are in the beta segment.
	segment := "standard"
	matched := false
	if plan, ok := req.Context["plan"]; ok && plan == "premium" {
		segment = "beta"
		matched = true
	}

	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(TargetResponse{
		UserID:  req.UserID,
		Matched: matched,
		Segment: segment,
	})
}

func main() {
	port := os.Getenv("PORT")
	if port == "" {
		port = "8082"
	}

	mux := http.NewServeMux()
	mux.HandleFunc("/health", healthHandler)
	mux.HandleFunc("/targeting/evaluate", evaluateHandler)

	log.Printf("targeting service listening on :%s", port)
	if err := http.ListenAndServe(":"+port, mux); err != nil {
		log.Fatalf("server error: %v", err)
	}
}
