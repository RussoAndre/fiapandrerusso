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
		t.Errorf("expected status 200, got %d", rr.Code)
	}

	var resp HealthResponse
	if err := json.NewDecoder(rr.Body).Decode(&resp); err != nil {
		t.Fatalf("failed to decode response: %v", err)
	}
	if resp.Status != "ok" {
		t.Errorf("expected status 'ok', got '%s'", resp.Status)
	}
	if resp.Service != "auth" {
		t.Errorf("expected service 'auth', got '%s'", resp.Service)
	}
}

func TestTokenHandler_Success(t *testing.T) {
	body, _ := json.Marshal(TokenRequest{Username: "admin", Password: "secret"})
	req := httptest.NewRequest(http.MethodPost, "/auth/token", bytes.NewReader(body))
	req.Header.Set("Content-Type", "application/json")
	rr := httptest.NewRecorder()

	tokenHandler(rr, req)

	if rr.Code != http.StatusOK {
		t.Errorf("expected status 200, got %d", rr.Code)
	}

	var resp TokenResponse
	if err := json.NewDecoder(rr.Body).Decode(&resp); err != nil {
		t.Fatalf("failed to decode response: %v", err)
	}
	if resp.Token == "" {
		t.Error("expected a non-empty token")
	}
}

func TestTokenHandler_MissingFields(t *testing.T) {
	body, _ := json.Marshal(TokenRequest{Username: "admin"})
	req := httptest.NewRequest(http.MethodPost, "/auth/token", bytes.NewReader(body))
	rr := httptest.NewRecorder()

	tokenHandler(rr, req)

	if rr.Code != http.StatusBadRequest {
		t.Errorf("expected status 400, got %d", rr.Code)
	}
}

func TestTokenHandler_WrongMethod(t *testing.T) {
	req := httptest.NewRequest(http.MethodGet, "/auth/token", nil)
	rr := httptest.NewRecorder()

	tokenHandler(rr, req)

	if rr.Code != http.StatusMethodNotAllowed {
		t.Errorf("expected status 405, got %d", rr.Code)
	}
}
