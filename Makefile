# パラメータ
GOCMD=go
GOBUILD=$(GOCMD) build
GOCLEAN=$(GOCMD) clean
GOTEST=$(GOCMD) test
GOGET=$(GOCMD) get
BINARY_NAME=gobinary

.PHONY: init
init: clean deps test precommit build

.PHONY: all
all: test precommit build run

.PHONY: build
build:
	$(GOBUILD) -o $(BINARY_NAME) -v

.PHONY: test
test:
	$(GOCMD) test ./...

.PHONY: clean
clean:
	$(GOCLEAN)
	rm -f $(BINARY_NAME)

.PHONY: run
run:
	./$(BINARY_NAME)

.PHONY: deps
deps:
	$(GOGET) github.com/golang/dep/cmd/dep
	$(GOGET) golang.org/x/lint/golint
	$(GOGET) golang.org/x/tools/cmd/goimports
	$(GOGET) github.com/kisielk/errcheck
	dep ensure

.PHONY: precommit
precommit :
	# 静的解析
	go list ./... | grep -v 'vendor' | xargs go vet
	# go lint
	go list ./... | grep -v 'vendor' | xargs golint -set_exit_status
	# go fmt
	find . -name '*.go' | grep -v 'vendor' | xargs gofmt -l
	# エラーハンドリングの確認
	# test と　Close の部分を無視している
	errcheck -ignoretests -ignore 'Close' ./...