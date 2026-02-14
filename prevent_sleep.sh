#!/bin/bash

DURATION=${1:-3600}

cleanup() {
  sudo systemctl unmask sleep.target suspend.target hibernate.target hybrid-sleep.target
  echo "✔ Suspend re-enabled"
}

# Ensure cleanup always runs
trap cleanup EXIT INT TERM

echo "⛔ Disabling suspend for $DURATION seconds..."
sudo systemctl mask sleep.target suspend.target hibernate.target hybrid-sleep.target

sleep "$DURATION"

echo "⏱ Time elapsed"
