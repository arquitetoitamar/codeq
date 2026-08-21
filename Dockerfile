# Build stage
FROM golang:1.23-alpine AS builder

# Install git (required for go mod download)
RUN apk add --no-cache git

WORKDIR /app

# Copy go mod files
COPY go.mod go.sum ./

# Copy all source (includes vendor if exists)
COPY . .

# Download dependencies (will use vendor if available)
RUN go mod download || true

# Build binary
RUN CGO_ENABLED=0 GOOS=linux go build -a -installsuffix cgo -o codeq-server ./cmd/codeq

# Runtime stage
FROM alpine:latest

RUN apk --no-cache add ca-certificates

WORKDIR /root/

# Copy binary from builder
COPY --from=builder /app/codeq-server .

# Expose port
EXPOSE 8080

# Run
CMD ["./codeq-server"]
