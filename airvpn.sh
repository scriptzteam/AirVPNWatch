#!/bin/bash

API_URL="https://airvpn.org/api/status/"

# Fetch JSON data
json=$(curl -s "$API_URL")

if [[ -z "$json" ]]; then
  echo "Failed to fetch data from API"
  exit 1
fi

# Print table header
printf "%-12s | %-15s | %-10s | %-15s | %-8s | %-8s | %-6s | %-8s | %-40s | %-70s | %-6s\n" \
  "Public Name" "Country Name" "Country" "Location" "Bw(Mbps)" "MaxBw" "Users" "Load(%)" "IPv4 Addresses" "IPv6 Addresses" "Health"
printf -- "--------------------------------------------------------------------------------------------------------------------------------------------------------------\n"

# Parse and print each server info in a table row
echo "$json" | jq -r '
  .servers[] |
  [
    .public_name,
    .country_name,
    .country_code,
    .location,
    (.bw | tostring),
    (.bw_max | tostring),
    (.users | tostring),
    (.currentload | tostring),
    ([.ip_v4_in1, .ip_v4_in2, .ip_v4_in3, .ip_v4_in4] | join(", ")),
    ([.ip_v6_in1, .ip_v6_in2, .ip_v6_in3, .ip_v6_in4] | join(", ")),
    .health
  ] | @tsv
' | while IFS=$'\t' read -r name country_name country_code location bw bwmax users load ipv4 ipv6 health; do
  printf "%-12s | %-15s | %-10s | %-15s | %-8s | %-8s | %-6s | %-8s | %-40s | %-70s | %-6s\n" \
    "$name" "$country_name" "$country_code" "$location" "$bw" "$bwmax" "$users" "$load" "$ipv4" "$ipv6" "$health"
done
