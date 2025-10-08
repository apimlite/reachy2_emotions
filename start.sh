#!/bin/bash

# Graceful shutdown on Ctrl+C / SIGTERM
EMOTION_PID=""
NPM_PID=""
STARTED_REACHY2=0
CLEANED_UP=0

cleanup() {
    # Prevent double execution
    if [ "$CLEANED_UP" -eq 1 ]; then
        return
    fi
    CLEANED_UP=1

    echo "\nShutting down..."

    # Stop npm dev server (and its children)
    if [ -n "$NPM_PID" ] && ps -p "$NPM_PID" > /dev/null 2>&1; then
        echo "Stopping UI server (PID: $NPM_PID)..."
        kill -TERM -"$NPM_PID" 2>/dev/null || kill -TERM "$NPM_PID" 2>/dev/null || true
        for i in {1..10}; do
            if ps -p "$NPM_PID" > /dev/null 2>&1; then sleep 1; else break; fi
        done
        if ps -p "$NPM_PID" > /dev/null 2>&1; then
            echo "Force killing UI server (PID: $NPM_PID)..."
            kill -KILL -"$NPM_PID" 2>/dev/null || kill -KILL "$NPM_PID" 2>/dev/null || true
        fi
    fi

    # Stop emotion server (and its children)
    if [ -n "$EMOTION_PID" ] && ps -p "$EMOTION_PID" > /dev/null 2>&1; then
        echo "Stopping emotion server (PID: $EMOTION_PID)..."
        kill -TERM -"$EMOTION_PID" 2>/dev/null || kill -TERM "$EMOTION_PID" 2>/dev/null || true
        for i in {1..10}; do
            if ps -p "$EMOTION_PID" > /dev/null 2>&1; then sleep 1; else break; fi
        done
        if ps -p "$EMOTION_PID" > /dev/null 2>&1; then
            echo "Force killing emotion server (PID: $EMOTION_PID)..."
            kill -KILL -"$EMOTION_PID" 2>/dev/null || kill -KILL "$EMOTION_PID" 2>/dev/null || true
        fi
    fi

    # Stop docker container only if we started it
    if [ "$STARTED_REACHY2" -eq 1 ]; then
        echo "Stopping Reachy2 Docker..."
        docker stop reachy2 >/dev/null 2>&1 || true
    fi

    # Deactivate venv if active
    if type deactivate >/dev/null 2>&1; then
        deactivate 2>/dev/null || true
    fi

    echo "Shutdown complete."
}

trap 'cleanup; exit 130' INT
trap 'cleanup; exit 143' TERM
trap 'cleanup' EXIT

# check if reachy2 docker is running, if not start it
if [ "$(docker ps -q -f name=reachy2)" ]; then
    echo "Reachy2 Docker is running"
else
    echo "Starting Reachy2 Docker..."
    if docker start reachy2; then
        STARTED_REACHY2=1
    fi
fi

echo "Waiting for Reachy2 to boot up..."
sleep 10

# activate venv
source venv/bin/activate

# start emotion server in background
# Run in its own session so we can terminate the whole group
setsid emotion-play --server &
EMOTION_PID=$!

echo "Emotion server started (PID: $EMOTION_PID)."
sleep 5

# start npm dev server in background
cd console/openai-realtime-console
# Run in its own session so we can terminate the whole group
setsid npm run dev &
NPM_PID=$!

echo "Simulation UI: http://localhost:6080/vnc.html?autoconnect=1&resize=remote"
echo "UI started    : http://localhost:3000"
echo "Press [CTRL+C] to stop.."

# keep script alive until both background processes exit
wait $EMOTION_PID $NPM_PID
