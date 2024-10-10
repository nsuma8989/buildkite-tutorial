#!/bin/bash

# Define log file name and target size (1MB = 1048576 bytes)
LOGFILE="large_log_file.log"
TARGET_SIZE=$((1024 * 1024))  # 1 MB in bytes

# Create or clear the log file
> "$LOGFILE"

# Loop until the file size is greater than 1MB
while [ $(stat -c%s "$LOGFILE") -le $TARGET_SIZE ]
do
  # Append random data to the log file
  echo "$(date) - Random log entry: $RANDOM" >> "$LOGFILE"
done

# Output the size of the generated log file
echo "Generated log file size: $(stat -c%s "$LOGFILE") bytes"
