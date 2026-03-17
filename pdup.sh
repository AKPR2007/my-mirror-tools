#!/bin/bash
MINPARAMS=1
PDSERVER="https://pixeldrain.com"
API_KEY=":<api-key>" #<==== Replace this https://pixeldrain.com/user/api_keys

# Create log file with timestamp
LOGFILE="/tmp/pixeldrain_upload_$(date +%Y%m%d_%H%M%S).log"

# Function to log messages
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOGFILE"
}

log "=== Upload session started ==="
log "Log file: $LOGFILE"

for FILE in "$@"
do
	FILENAME="${FILE##*/}"

	log "Uploading $FILENAME ..."
	echo "Uploading $FILENAME ... "
	
	RESPONSE=$(curl -# -F "name=$FILENAME" -u $API_KEY -F "file=@$FILE" $PDSERVER/api/file)
	
	# Log the raw response
	echo "[$(date '+%Y-%m-%d %H:%M:%S')] Response: $RESPONSE" >> "$LOGFILE"
	
	if echo "$RESPONSE" | grep -q '"success":false'; then
		# Extract and print the message
		MESSAGE=$(echo "$RESPONSE" | grep -Po '(?<="message":")[^"]*')
		log "Error: $MESSAGE"
		echo "Error: $MESSAGE"
	else
		# Extract the ID
		FILEID=$(echo "$RESPONSE" | grep -Po '(?<="id":")[^"]*')
		log "Success! File ID: $FILEID"
		log "URL: $PDSERVER/u/$FILEID"
		echo "Your file URL: $PDSERVER/u/$FILEID"
	fi
done

log "=== Upload session completed ==="
echo "" # Move cursor down when script finishes
