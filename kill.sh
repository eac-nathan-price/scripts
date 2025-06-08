#!/bin/bash

# Define common ports to check
PORTS=(
  # Firebase Emulators
  4000  # Emulator UI
  4400  # Emulator Hub
  4500  # Logging
  5000  # Hosting
  5001  # Functions
  5002  # Custom Dev Server
  8080  # Firestore
  8085  # Pub/Sub
  9000  # Realtime Database
  9099  # Auth
  9150  # Firestore WebSocket
  9199  # Storage

  # Common Web Frameworks & CLI
  3000  # Default Node/React
  3333  # Nx API
  4200  # Angular/Nx default
  4201  # Secondary Angular
  5173  # Vite
  8000  # Generic HTTP
  9222  # Chrome Remote Debugging
)

echo "Searching for processes on common ports..."

found_any=false

for port in "${PORTS[@]}"; do
  # Find PIDs using the port
  pids=$(lsof -t -i:$port 2>/dev/null)
  
  if [ -n "$pids" ]; then
    found_any=true
    echo "Killing processes on port $port (PIDs: $(echo $pids | tr '\n' ' '))"
    echo "$pids" | xargs kill -9 2>/dev/null
  fi
done

if [ "$found_any" = false ]; then
  echo "No processes found on monitored ports."
else
  echo "Cleanup complete."
fi
