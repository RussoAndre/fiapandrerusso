package main

import (
	"bytes"
	"encoding/json"
	"net/http"
	"net/http/httptest"
	"testing"
)

func TestHealthHandler(t *testing.T) {
	req := httptest.NewRequest(http.MethodGet, "/health", nil)
	rr := httptest.NewRecorder()
	healthHandler(rr, req)

	if rr.Code != http.StatusOK {
		t.Errorf("expected 200, got %d", rr.Code)
	}
	var resp HealthResponse
	json.NewDecoder(rr.Body).Decode(&resp)
	if resp.Service != "evaluation" {
		t.Errorf("expected service 'evaluation', got '%s'", resp.Service)
	}
}

func TestEvalHandler_PremiumGetsFlag(t *testing.T) {
	payload := EvalRequest{
		FlagKey: "new-ui",
		UserID:  "u1",
		Context: map[string]string{"plan": "premium"},
	}
	body, _ := json.Marshal(payload)
	req := httptest.NewRequest(http.MethodPost, "/evaluation/eval", bytes.NewReader(body))
	req.Header.Set("Content-Type", "application/json")
	rr := httptest.NewRecorder()
	evalHandler(rr, req)

	if rr.Code != http.StatusOK {
		t.Errorf("expected 200, got %d", rr.Code)
	}
	var resp EvalResponse
	json.NewDecoder(rr.Body).Decode(&resp)
	if !resp.Value {
		t.Error("expected value=true for premium user")
	}
	if resp.Reason != "TARGETING_MATCH" {
		t.Errorf("unexpected reason: %s", resp.Reason)
	}
}

func TestEvalHandler_FreeUserDoesNotGetFlag(t *testing.T) {
	payload := EvalRequest{
		FlagKey: "new-ui",
		UserID:  "u2",
		Context: map[string]string{"plan": "free"},
	}
	body, _ := json.Marshal(payload)
	req := httptest.NewRequest(http.MethodPost, "/evaluation/eval", bytes.NewReader(body))
	rr := httptest.NewRecorder()
	evalHandler(rr, req)

	if rr.Code != http.StatusOK {
		t.Errorf("expected 200, got %d", rr.Code)
	}
	var resp EvalResponse
	json.NewDecoder(rr.Body).Decode(&resp)
	if resp.Value {
		t.Error("expected value=false for free user")
	}
}

func TestEvalHandler_MissingFields(t *testing.T) {
	payload := EvalRequest{FlagKey: "new-ui"}
	body, _ := json.Marshal(payload)
	req := httptest.NewRequest(http.MethodPost, "/evaluation/eval", bytes.NewReader(body))
	rr := httptest.NewRecorder()
	evalHandler(rr, req)

	if rr.Code != http.StatusBadRequest {
		t.Errorf("expected 400, got %d", rr.Code)
	}
}
