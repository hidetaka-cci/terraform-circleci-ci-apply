#!/usr/bin/env bash
# この pipeline のコミットが main の先頭と同じかを調べる。
# 使い方: check-latest-main.sh report|cancel
set -euo pipefail

mode="${1:?usage: $0 report|cancel}"
: "${CIRCLE_SHA1:?CIRCLE_SHA1 が空}"

if ! out=$(git ls-remote --exit-code origin refs/heads/main); then
  echo "main の先頭のコミットを取得できなかった（git ls-remote）。最新かどうか判断できないので止める" >&2
  exit 1
fi
latest="${out%%[[:space:]]*}"
if ! [[ "$latest" =~ ^[0-9a-f]{40}$ ]]; then
  echo "main の先頭のコミットの形式が想定外（${latest}）。最新かどうか判断できないので止める" >&2
  exit 1
fi

if [ "$latest" = "$CIRCLE_SHA1" ]; then
  echo "この pipeline のコミット ${CIRCLE_SHA1} は main の最新"
  exit 0
fi

echo "main の先頭のコミットは ${latest}（この pipeline は ${CIRCLE_SHA1}）"
if [ "$mode" = "cancel" ]; then
  : "${CIRCLE_WORKFLOW_ID:?CIRCLE_WORKFLOW_ID が空}"
  : "${CIRCLE_TOKEN:?CIRCLE_TOKEN が空（context が必要）}"
  echo "main に新しいコミットがあるので、この pipeline では apply せず、この workflow をキャンセルする。新しいコミットの pipeline で apply する"
  circleci workflow cancel --force "${CIRCLE_WORKFLOW_ID}"
  # キャンセルが効くとこの job は止められる。効かないまま apply に進まないよう待ち、止まらなければ失敗させる
  sleep 120
  echo "キャンセルが 120 秒以内に効かなかった。apply せずに失敗させる" >&2
  exit 1
fi
