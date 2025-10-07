#!/bin/bash

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

cp .env.example .env

cp .env console/openai-realtime-console/.env

cd console/openai-realtime-console

npm install
