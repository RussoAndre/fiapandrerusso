FROM golang:1.21-alpine AS builder
WORKDIR /app
COPY go.mod ./
RUN go mod download
COPY . .
RUN CGO_ENABLED=0 GOOS=linux go build -o evaluation .

FROM gcr.io/distroless/static:nonroot
WORKDIR /app
COPY --from=builder /app/evaluation .
EXPOSE 8083
USER nonroot:nonroot
ENTRYPOINT ["/app/evaluation"]
