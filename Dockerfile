FROM --platform=$BUILDPLATFORM golang:1.24 AS builder

WORKDIR /workspace

# Copy the Go Modules manifests
COPY go.mod go.mod
COPY go.sum go.sum
# cache deps before building and copying source so that we don't need to re-download as much
# and so that source changes don't invalidate our downloaded layer
RUN go mod download

# Copy the go source
COPY ./ ./

ARG TARGETARCH
ARG TARGETOS

# Build
RUN CGO_ENABLED=0 GOOS=$TARGETOS GOARCH=$TARGETARCH go build -a -o rpc-api cmd/bmc/main.go

FROM scratch
COPY --from=builder /workspace/rpc-api /
ENTRYPOINT ["/rpc-api"]
