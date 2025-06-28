#!/usr/bin/env bash

KIBANA_URL=${args[--url]:-"https://localhost:5601"}
USERNAME=${args[--username]:-"elastic"}
PASSWORD=${args[--password]:-"changeme"}
FORMAT=${args[--format]:-"csv"}
PAGE_SIZE=${args[--page_size]:-"1000"}
SKIP_TLS=${args[--insecure]}
# Load requested columns or use default set
if [[ -n "${args[--column]}" ]]; then
  eval "COLUMNS=(${args[--column]})"
else
  COLUMNS=(name description tags query)
fi


# Fetch rules from Kibana
curl_flags=(-sSL --fail)
[[ -n "$SKIP_TLS" ]] && curl_flags+=(--insecure)

if response=$(curl "${curl_flags[@]}" \
    -u "$USERNAME:$PASSWORD" \
    -H "kbn-xsrf: true" \
    "$KIBANA_URL/api/detection_engine/rules/_find?filter=alert.attributes.enabled:true&per_page=$PAGE_SIZE" 2>&1); then

  echo "🔍 Fetched $(echo "$response" | jq '.data | length') rules."
else
  echo "❌ Failed to fetch rules from Kibana:"
  echo "$response"
  exit 1
fi

# Get available keys from the first rule
AVAILABLE=($(echo "$response" | jq -r '.data[0] | keys[]'))

for col in "${COLUMNS[@]}"; do
  if ! [[ " ${AVAILABLE[*]} " == *" $col "* ]]; then
    echo "❌ Invalid column: $col"
    echo "Valid options: ${AVAILABLE[*]}"
    exit 1
  fi
done

# Generate headers dynamically from the specified columns
header=""
for col in "${COLUMNS[@]}"; do
  header+="${col^},"    # capitalize header
done
header=${header%,}      # trim trailing comma

if [[ "$FORMAT" == "csv" ]]; then
  echo "$header" > "$OUTPUT"
elif [[ "$FORMAT" == "markdown" ]]; then
  IFS=',' read -ra headers <<< "$header"
  # Build markdown table header and divider
  {
    printf "| %s |\n" "$(IFS=' | '; echo "${headers[*]}")"
    printf "|%s|\n" "$(printf ' --- |%.0s' "${headers[@]}")"
  } > "$OUTPUT"
fi

# Parse and export
echo "🔧 Processing the response..."
if [ "$FORMAT" == "json" ]; then
    echo "$response" | jq > "$OUTPUT"
else
  echo "$response" | jq -c '.data[]' | while read -r obj; do
  row=()
  for col in "${COLUMNS[@]}"; do
    val=$(echo "$obj" | jq -r --arg c "$col" '
      if $c=="tags" then (.tags | join(", "))
      else .[$c]
      end' | tr '\n' ' ' | sed 's/|/\\|/g')

    if [[ "$FORMAT" == "csv" ]]; then
      val="${val//\"/\"\"}"
    else
      [[ ${#val} -gt 200 ]] && val="${val:0:200}…"
      val="\`$val\`"
    fi
    row+=("$val")
  done

  IFS=, eval 'out="${row[*]}"'

  if [[ "$FORMAT" == "csv" ]]; then
    echo "\"$out\"" >> "$OUTPUT"
  else
    printf "| %s |\n" "$(IFS=' | '; echo "${row[*]}")" >> "$OUTPUT"
  fi
  done
fi

echo "✅ Done! Output saved to $OUTPUT"
