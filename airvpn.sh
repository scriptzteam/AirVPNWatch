#!/bin/bash

API_URL="https://airvpn.org/api/status/"

json=$(curl -s "$API_URL")

echo "| Public Name | Country Name | Country | Location | Bw(Mbps) | MaxBw | Users | Load(%) | IPv4 Addresses | IPv6 Addresses | Health |"
echo "|-------------|--------------|---------|----------|----------|-------|-------|---------|---------------|---------------|--------|"

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
  # Escape any pipes in data to avoid breaking Markdown formatting
  name="${name//|/\\|}"
  country_name="${country_name//|/\\|}"
  country_code="${country_code//|/\\|}"
  location="${location//|/\\|}"
  ipv4="${ipv4//|/\\|}"
  ipv6="${ipv6//|/\\|}"
  health="${health//|/\\|}"

  echo "| $name | $country_name | $country_code | $location | $bw | $bwmax | $users | $load | $ipv4 | $ipv6 | $health |"
done
