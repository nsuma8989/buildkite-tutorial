#!/bin/bash

echo "signal termination handler script"

shell_event_handler() {
    echo "${1} received."

    case "${1}" in
        "SIGTERM")
            exit 143
            ;;
        "SIGHUP")
            exit 129
            ;;
        "SIGINT")
            exit 130
            ;;
        "SIGKILL")
            exit 137
            ;;
        "SIGQUIT")
            exit 131
            ;;
        *)
            exit 1
            ;;
    esac
}

trap 'shell_event_handler SIGTERM' SIGTERM
trap 'shell_event_handler SIGHUP' SIGHUP
trap 'shell_event_handler SIGINT' SIGINT
trap 'shell_event_handler SIGKILL' SIGKILL
trap 'shell_event_handler SIGQUIT' SIGQUIT

sleep 300

if [ $? -ne 0 ]; then
  echo "error occurred when running sleep command"
  exit 1
fi
