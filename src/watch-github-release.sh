#!/bin/bash

# Define log file name and target size (1MB = 1048576 bytes)
LOGFILE="large_log_file.log"
TARGET_SIZE=$((1024 * 1024))  # 1 MB in bytes

# Create or clear the log file
> "$LOGFILE"

# Loop until the file size is greater than 1MB
while [ $(stat -f%z "$LOGFILE") -le $TARGET_SIZE ]
do
  # Generate a log entry
  log_entry="$(date) - Random log entry: $RANDOM"

  # Output the log entry to both stdout and the log file
  echo "$log_entry" | tee -a "$LOGFILE"
done

# Output the size of the generated log file
echo "Generated log file size: $(stat -f%z "$LOGFILE") bytes"

