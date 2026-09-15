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
}

func TestEvaluateHandler_PremiumSegment(t *testing.T) {
	payload := TargetRequest{
		UserID:  "user-123",
		Context: map[string]string{"plan": "premium"},
	}
	body, _ := json.Marshal(payload)
	req := httptest.NewRequest(http.MethodPost, "/targeting/evaluate", bytes.NewReader(body))
	req.Header.Set("Content-Type", "application/json")
	rr := httptest.NewRecorder()
	evaluateHandler(rr, req)

	if rr.Code != http.StatusOK {
		t.Errorf("expected 200, got %d", rr.Code)
	}
	var resp TargetResponse
	json.NewDecoder(rr.Body).Decode(&resp)
	if !resp.Matched {
		t.Error("expected matched=true for premium user")
	}
	if resp.Segment != "beta" {
		t.Errorf("expected segment 'beta', got '%s'", resp.Segment)
	}
}

func TestEvaluateHandler_StandardSegment(t *testing.T) {
	payload := TargetRequest{
		UserID:  "user-456",
		Context: map[string]string{"plan": "free"},
	}
	body, _ := json.Marshal(payload)
	req := httptest.NewRequest(http.MethodPost, "/targeting/evaluate", bytes.NewReader(body))
	rr := httptest.NewRecorder()
	evaluateHandler(rr, req)

	if rr.Code != http.StatusOK {
		t.Errorf("expected 200, got %d", rr.Code)
	}
	var resp TargetResponse
	json.NewDecoder(rr.Body).Decode(&resp)
	if resp.Matched {
		t.Error("expected matched=false for free user")
	}
}

func TestEvaluateHandler_MissingUserID(t *testing.T) {
	payload := TargetRequest{Context: map[string]string{"plan": "premium"}}
	body, _ := json.Marshal(payload)
	req := httptest.NewRequest(http.MethodPost, "/targeting/evaluate", bytes.NewReader(body))
	rr := httptest.NewRecorder()
	evaluateHandler(rr, req)

	if rr.Code != http.StatusBadRequest {
		t.Errorf("expected 400, got %d", rr.Code)
	}
}

func TestEvaluateHandler_WrongMethod(t *testing.T) {
	req := httptest.NewRequest(http.MethodGet, "/targeting/evaluate", nil)
	rr := httptest.NewRecorder()
	evaluateHandler(rr, req)

	if rr.Code != http.StatusMethodNotAllowed {
		t.Errorf("expected 405, got %d", rr.Code)
	}
}
