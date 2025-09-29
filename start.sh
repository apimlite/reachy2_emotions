#!/bin/bash

# check is reachy2 docker is running if not start it
# docker start reachy2

if [ "$(docker ps -q -f name=reachy2)" ]; then
    echo "Reachy2 Docker is running"
else
    echo "Starting Reachy2 Docker..."
    docker start reachy2
fi

echo "Waiting for Reachy2 to boot up..."
sleep 10

source .venv/bin/activate

emotion-play --server

echo "Emotion server started."
sleep 5

cd console/openai-realtime-console

npm run dev

echo "Simulation UI: http://localhost:6080/vnc.html?autoconnect=1&resize=remote"
echo "UI started : http://localhost:3000"
echo "Press [CTRL+C] to stop.."