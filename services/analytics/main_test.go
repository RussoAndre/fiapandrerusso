package main

import (
	"bytes"
	"encoding/json"
	"net/http"
	"net/http/httptest"
	"testing"
)

func resetEvents() {
	mu.Lock()
	events = nil
	mu.Unlock()
}

func TestHealthHandler(t *testing.T) {
	req := httptest.NewRequest(http.MethodGet, "/health", nil)
	rr := httptest.NewRecorder()
	healthHandler(rr, req)

	if rr.Code != http.StatusOK {
		t.Errorf("expected 200, got %d", rr.Code)
	}
	var resp HealthResponse
	json.NewDecoder(rr.Body).Decode(&resp)
	if resp.Service != "analytics" {
		t.Errorf("expected service 'analytics', got '%s'", resp.Service)
	}
}

func TestTrackHandler_Success(t *testing.T) {
	resetEvents()
	payload := Event{FlagKey: "new-ui", UserID: "u1", Value: true}
	body, _ := json.Marshal(payload)
	req := httptest.NewRequest(http.MethodPost, "/analytics/track", bytes.NewReader(body))
	req.Header.Set("Content-Type", "application/json")
	rr := httptest.NewRecorder()
	trackHandler(rr, req)

	if rr.Code != http.StatusCreated {
		t.Errorf("expected 201, got %d", rr.Code)
	}
}

func TestTrackHandler_MissingFields(t *testing.T) {
	payload := Event{FlagKey: "new-ui"}
	body, _ := json.Marshal(payload)
	req := httptest.NewRequest(http.MethodPost, "/analytics/track", bytes.NewReader(body))
	rr := httptest.NewRecorder()
	trackHandler(rr, req)

	if rr.Code != http.StatusBadRequest {
		t.Errorf("expected 400, got %d", rr.Code)
	}
}

func TestSummaryHandler(t *testing.T) {
	resetEvents()
	// Track two events
	for _, v := range []bool{true, false} {
		payload := Event{FlagKey: "new-ui", UserID: "u1", Value: v}
		body, _ := json.Marshal(payload)
		req := httptest.NewRequest(http.MethodPost, "/analytics/track", bytes.NewReader(body))
		rr := httptest.NewRecorder()
		trackHandler(rr, req)
	}

	req := httptest.NewRequest(http.MethodGet, "/analytics/summary", nil)
	rr := httptest.NewRecorder()
	summaryHandler(rr, req)

	if rr.Code != http.StatusOK {
		t.Errorf("expected 200, got %d", rr.Code)
	}
	var result []Summary
	json.NewDecoder(rr.Body).Decode(&result)
	if len(result) == 0 {
		t.Error("expected at least one summary entry")
	}
}
