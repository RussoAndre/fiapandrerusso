package main

import (
	"encoding/json"
	"log"
	"net/http"
	"os"
)

type HealthResponse struct {
	Status  string `json:"status"`
	Service string `json:"service"`
}

type EvalRequest struct {
	FlagKey string            `json:"flag_key"`
	UserID  string            `json:"user_id"`
	Context map[string]string `json:"context"`
}

type EvalResponse struct {
	FlagKey string `json:"flag_key"`
	UserID  string `json:"user_id"`
	Value   bool   `json:"value"`
	Reason  string `json:"reason"`
}

func healthHandler(w http.ResponseWriter, r *http.Request) {
	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(HealthResponse{Status: "ok", Service: "evaluation"})
}

func evalHandler(w http.ResponseWriter, r *http.Request) {
	if r.Method != http.MethodPost {
		http.Error(w, "method not allowed", http.StatusMethodNotAllowed)
		return
	}
	var req EvalRequest
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		http.Error(w, "invalid request body", http.StatusBadRequest)
		return
	}
	if req.FlagKey == "" || req.UserID == "" {
		http.Error(w, "flag_key and user_id are required", http.StatusBadRequest)
		return
	}

	value := false
	reason := "DEFAULT_OFF"
	if req.FlagKey == "new-ui" {
		if plan, ok := req.Context["plan"]; ok && plan == "premium" {
			value = true
			reason = "TARGETING_MATCH"
		}
	}

	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(EvalResponse{
		FlagKey: req.FlagKey,
		UserID:  req.UserID,
		Value:   value,
		Reason:  reason,
	})
}

func main() {
	port := os.Getenv("PORT")
	if port == "" {
		port = "8083"
	}

	mux := http.NewServeMux()
	mux.HandleFunc("/health", healthHandler)
	mux.HandleFunc("/evaluation/eval", evalHandler)

	log.Printf("evaluation service listening on :%s", port)
	if err := http.ListenAndServe(":"+port, mux); err != nil {
		log.Fatalf("server error: %v", err)
	}
}
