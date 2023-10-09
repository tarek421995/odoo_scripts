#!/bin/bash

DIRECTORY_TO_OBSERVE="/opt/odoo16"
while true; do
  change=$(inotifywait -r -e close_write,moved_to,create "$DIRECTORY_TO_OBSERVE")
  change=${change#"$DIRECTORY_TO_OBSERVE"}
  echo "$change detected. Restarting Odoo..."
  sudo systemctl restart odoo16
  echo "Odoo restarted!"
done
