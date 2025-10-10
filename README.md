# Reachy2 Emotions - Docker Compose

This repo includes a docker-compose setup to run:
- Reachy2 simulator container
- Python emotions Flask server (serves POST /play_emotion on port 5001)
- Web console (Fastify + React on port 3000)

## Quick start

1) Create a .env for the console

Copy `.env.example` to `.env` and set `OPENAI_API_KEY`.

2) Build and start

Use Docker Compose to build and start all services in the background.

3) Open the UIs
- Reachy noVNC: http://localhost:6080/vnc.html?autoconnect=1&resize=remote
- Console UI:  http://localhost:3000

The console posts function calls to the Flask endpoint at http://localhost:5002/play_emotion, which drives the Reachy2 simulator through the SDK.

## Notes
- The emotions service talks to host `reachy2` (the simulator service) by default.
- Data recordings are baked into the image; if you plan to edit them live, mount a volume to `/app/data` and rebuild if necessary.
- If you need audio output from the container, additional host audio setup is required; the default setup is headless.