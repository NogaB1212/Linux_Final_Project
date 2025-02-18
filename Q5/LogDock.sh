#!/usr/bin/env bash

LOGFILE="containers_files.log"

# Start a fresh log file
echo "[INFO] Listing files from each running container at $(date)" > "$LOGFILE"

# Loop over ALL containers (including stopped)
# If you only want currently running containers, use 'docker ps -q' instead of 'docker ps -a -q'
for container_id in $(docker ps -a -q); do
  
  # Get container name and status
  name=$(docker inspect -f '{{.Name}}' "$container_id" | cut -c2-)
  status=$(docker inspect -f '{{.State.Status}}' "$container_id")

  echo "===== Container: $name (ID: $container_id, Status: $status) =====" >> "$LOGFILE"

  # Only 'docker exec' if the container is running
  if [ "$status" = "running" ]; then
    # For example, list recursively in /data. Adjust path if needed:
    docker exec "$container_id" ls -R /data >> "$LOGFILE" 2>&1 || {
      echo "[WARN] Could not list /data inside $name. Maybe /data doesn't exist?" >> "$LOGFILE"
    }
  else
    echo "[INFO] Container $name is not running; cannot list files via 'docker exec'." >> "$LOGFILE"
  fi

  echo "" >> "$LOGFILE"
done

echo "[INFO] Finished logging at $(date)" >> "$LOGFILE"

echo "Log created: $LOGFILE"