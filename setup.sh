#!/bin/bash

docker run -d --platform linux/amd64 \
  -p 8888:8888 -p 6080:6080 -p 50051:50051 -p 50065:50065 \
  --name reachy2 docker.io/pollenrobotics/reachy2

sudo apt-get install libportaudio2

# check venv folder if not create it
# Install venv if missing
apt update && apt install -y python3-venv

if [ ! -d "venv" ]; then
    echo "Creating virtual environment..."
    python3 -m venv venv
fi

source venv/bin/activate

pip install -e .

emotion-play --list

cp .env console/openai-realtime-console/.env

cd console/openai-realtime-console

npm install
