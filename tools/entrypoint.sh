#!/bin/sh
set -e

# Initial build
echo "Running initial build..."
make -C /var/www

TRIGGER="/tmp/rebuild_trigger"

# 1. File Watcher (Background)
# Monitors xml and xsls directories.
# Excludes generated files (dirindex.xml, varindex.xml) to prevent feedback loops.
echo "Starting file watcher..."
inotifywait -m -r \
    -e close_write,moved_to,create \
    --exclude '(dirindex|varindex)\.xml$' \
    --format '%w%f' \
    /var/www/xml /var/www/xsls \
| while read file; do
    touch "$TRIGGER"
done &

# 2. Builder Loop (Background)
# Checks for the trigger file periodically.
(
    while true; do
        if [ -f "$TRIGGER" ]; then
            # to debounce rapid-fire events (e.g. "Save All")
            sleep 1.0

            rm -f "$TRIGGER"

            echo "Changes detected. Rebuilding..."
            make -C /var/www || echo "Build failed. Fix the errors to trigger a rebuild."
        else
            # Polling interval
            sleep 1.0
        fi
    done
) &

# 3. Nginx (Foreground)
echo "NOTICE: nginx.org development site is running at http://localhost:8001/"
exec nginx -g 'daemon off;'
