``#!/usr/bin/env bash
#
# check-env.sh
# 檢查本機全端開發環境是否已安裝必要工具，並列出各工具版本。
# 用法: ./check-env.sh
#
set -uo pipefail

GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[0;33m'
BOLD='\033[1m'
NC='\033[0m' # No Color

MISSING=0

ok() {
  printf "  ${GREEN}✔${NC} %s\n" "$1"
}

fail() {
  printf "  ${RED}✘ 未安裝: %s${NC}\n" "$1"
  MISSING=1
}

warn() {
  printf "  ${YELLOW}⚠ %s${NC}\n" "$1"
}

section() {
  printf "\n${BOLD}%s${NC}\n" "$1"
}

section "== 1. Java (JDK) =="
if command -v java >/dev/null 2>&1; then
  JAVA_VER_LINE=$(java -version 2>&1 | head -n 1)
  ok "java: $JAVA_VER_LINE"
else
  fail "java (需要 JDK 21)"
fi

if command -v /usr/libexec/java_home >/dev/null 2>&1; then
  # 注意: `java_home -v 21` 在 macOS 上是「21 以上」的比對，不是精確比對，
  # 所以用完整列表 (-V) 找出版本號開頭確實是 "21." 的那一筆，才算真的裝了 JDK 21。
  JAVA21_HOME=$(/usr/libexec/java_home -V 2>&1 | grep -E '^[[:space:]]*21\.' | awk '{print $NF}' | head -n 1)
  if [ -n "$JAVA21_HOME" ]; then
    ok "偵測到 JDK 21: $JAVA21_HOME"
  else
    fail "JDK 21（系統上只有其他版本，請安裝 Temurin 21）"
  fi
fi

section "== 2. Maven =="
if command -v mvn >/dev/null 2>&1; then
  MVN_VER_LINE=$(mvn -v 2>&1 | head -n 1)
  ok "mvn: $MVN_VER_LINE"
else
  fail "mvn (Maven)"
fi

section "== 3. Git =="
if command -v git >/dev/null 2>&1; then
  ok "git: $(git --version)"
else
  fail "git"
fi

section "== 4. Node.js / npm =="
if command -v node >/dev/null 2>&1; then
  ok "node: $(node -v)"
else
  fail "node (需要 Node.js LTS)"
fi

if command -v npm >/dev/null 2>&1; then
  ok "npm: $(npm -v)"
else
  fail "npm"
fi

section "== 5. Docker =="
if command -v docker >/dev/null 2>&1; then
  ok "docker CLI: $(docker --version)"
  if docker info >/dev/null 2>&1; then
    ok "Docker 服務 (daemon) 已啟動"
  else
    fail "Docker 服務未啟動 (請打開 Docker Desktop 應用程式)"
  fi
else
  fail "docker (需要安裝 Docker Desktop)"
fi

echo
if [ "$MISSING" -eq 0 ]; then
  printf "${GREEN}${BOLD}所有工具皆已安裝並可使用。${NC}\n"
else
  printf "${RED}${BOLD}有工具尚未安裝或尚未啟動，請參考上方 ✘ 項目進行安裝。${NC}\n"
fi

exit $MISSING
