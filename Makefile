.PHONY: build build-all release-local clean install test help

# 默认：编译当前平台
build:
	go build -o gm ./cmd/gradmotion

# 编译所有平台
build-all:
	./scripts/build-all.sh

# 本地打包（GoReleaser snapshot）
release-local:
	./scripts/release-local.sh

# 清理产物
clean:
	rm -rf dist/ gm gm-*

# 安装到本地（macOS）
install: build
	sudo install -m 0755 gm /usr/local/bin/gm

# 运行测试
test:
	go test -v ./...

# 帮助
help:
	@echo "Gradmotion CLI Makefile"
	@echo ""
	@echo "Usage:"
	@echo "  make build          - 编译当前平台"
	@echo "  make build-all      - 编译所有平台（无需 git）"
	@echo "  make release-local  - GoReleaser 本地打包（需 git）"
	@echo "  make clean          - 清理产物"
	@echo "  make install        - 安装到 /usr/local/bin（需 sudo）"
	@echo "  make test           - 运行测试"
	@echo ""
	@echo "环境变量："
	@echo "  VERSION=v0.1.0 make build-all  - 指定版本号"
