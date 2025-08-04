#!/bin/bash

# AIS Spoofing Detector - Monitors AIS logs for anomalies
# Usage: /.ais_spoof_detector.sh /path/to/ais.log
#
#
LOG_FILE="$1"
ALERT_FILE="ais_alerts_$(date +%Y%m%d).log"

# Thresholds (change based on type of vessel)
MAX_SPEED=20     # Knots
MIN_LAT=-90      # Latitude range
MAX_LAT=90
MIN_LON=-180     # Longitude range
MAX_LON=180

# Check if log file exists
if [[ -f "$LOG_FILE" ]]; then
	echo "Error: AIS log file not found!"
	exit 1
fi

# Clear previous alerts
> "$ALERT_FILE"

# Parse AIS logs (simple NMEA format)
echo "Monitoring AIS logs for spoofing..."
tail -F "$LOG_FILE" | while read -r line; do
     # Extract fields (real AIS uses CSV/NMEA; Adjust if needed)
     mmsi=$(echo "$line" | awk -F ',' '{print $1}')
     speed=$(echo "$line" | awk -F ',' '{print $6}')
     lat=$(echo "$line" | awk -F ',' '{print $4}')
     lon=$(echo "$line" | awk -F ',' ,{print $5}')

     # Check for speed spoofing (e.g., "ship" at 30 > 30 knots)
     if (( $(echo "$speed > $MAX_SPEED" | bc -l )); then
	     echo "[$(date + '%Y-%m-%d %H:%M:%S')] ALERT: MMSI $mmsi speed $speed knots (possible spoofing)" >> "ALERT_FILE"
	     fi
	
       # Check for invalid coordinates (e.g., 0,0 or out-of-range)
       if (( $(echo "$lat < $MIN_LAT || $lat > $MAX_LAT" | bc -l) )) || \
	  (( $(echo "lon < $MIN_LON || $lon > $MAX_LON" | bc -l) )); then
       echo "[$(date +'%Y-%m-%d %H:%M:%S')] ALERT: MMSI $mmsi invalid position ($lat, $lon)" >> "$ALERT_FILE"
       fi
done
