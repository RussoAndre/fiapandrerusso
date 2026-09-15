package main

import (
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
	if resp.Service != "flag" {
		t.Errorf("expected service 'flag', got '%s'", resp.Service)
	}
}

func TestListFlagsHandler(t *testing.T) {
	req := httptest.NewRequest(http.MethodGet, "/flags", nil)
	rr := httptest.NewRecorder()
	listFlagsHandler(rr, req)

	if rr.Code != http.StatusOK {
		t.Errorf("expected 200, got %d", rr.Code)
	}
	var list []Flag
	json.NewDecoder(rr.Body).Decode(&list)
	if len(list) == 0 {
		t.Error("expected at least one flag")
	}
}

func TestGetFlagHandler_Found(t *testing.T) {
	req := httptest.NewRequest(http.MethodGet, "/flags/get?key=new-ui", nil)
	rr := httptest.NewRecorder()
	getFlagHandler(rr, req)

	if rr.Code != http.StatusOK {
		t.Errorf("expected 200, got %d", rr.Code)
	}
}

func TestGetFlagHandler_NotFound(t *testing.T) {
	req := httptest.NewRequest(http.MethodGet, "/flags/get?key=nonexistent", nil)
	rr := httptest.NewRecorder()
	getFlagHandler(rr, req)

	if rr.Code != http.StatusNotFound {
		t.Errorf("expected 404, got %d", rr.Code)
	}
}

func TestGetFlagHandler_MissingKey(t *testing.T) {
	req := httptest.NewRequest(http.MethodGet, "/flags/get", nil)
	rr := httptest.NewRecorder()
	getFlagHandler(rr, req)

	if rr.Code != http.StatusBadRequest {
		t.Errorf("expected 400, got %d", rr.Code)
	}
}
