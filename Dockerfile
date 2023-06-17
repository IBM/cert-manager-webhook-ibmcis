FROM --platform=linux/amd64 golang:1.20.5-alpine AS build_deps

RUN apk add --no-cache git
RUN apk add --no-cache ca-certificates

WORKDIR /workspace
ENV GO111MODULE=on

COPY go.mod .
COPY go.sum .

RUN go mod tidy \
 && go version

FROM build_deps AS build

COPY . .

RUN CGO_ENABLED=0 go build -o webhook -ldflags '-w -extldflags "-static"' .

FROM scratch

COPY --from=build /workspace/webhook /usr/local/bin/webhook
COPY --from=build /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/ 
COPY --from=build /tmp /tmp

ENTRYPOINT ["webhook"]
