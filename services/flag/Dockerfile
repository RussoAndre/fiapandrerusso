FROM golang:1.21-alpine AS builder
WORKDIR /app
COPY go.mod ./
RUN go mod download
COPY . .
RUN CGO_ENABLED=0 GOOS=linux go build -o flag .

FROM gcr.io/distroless/static:nonroot
WORKDIR /app
COPY --from=builder /app/flag .
EXPOSE 8081
USER nonroot:nonroot
ENTRYPOINT ["/app/flag"]
