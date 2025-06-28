#!/usr/bin/env bash

KIBANA_URL=${args[--url]:-"https://localhost:5601"}
USERNAME=${args[--username]:-"elastic"}
PASSWORD=${args[--password]:-"changeme"}
FORMAT=${args[--format]:-"csv"}
FILTER=${args[--filter]:-"alert.attributes.enabled:true"}
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
    "$KIBANA_URL/api/detection_engine/rules/_find?filter=$FILTER&per_page=$PAGE_SIZE" 2>&1); then

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

# Set output
if [[ "$FORMAT" == "csv" ]]; then
  OUTPUT="rules.csv"
elif [[ "$FORMAT" == "markdown" ]]; then
  OUTPUT="rules.md"
else
  OUTPUT="rules.json"
fi

# Generate headers dynamically from the specified columns
header=""
for col in "${COLUMNS[@]}"; do
  header+="${col^},"    # capitalize header
done
header=${header%,}      # trim trailing comma

if [[ "$FORMAT" == "csv" ]]; then
  echo "$header" > "$OUTPUT"
elif [[ "$FORMAT" == "markdown" ]]; then
  formatted="| ${header//,/ | } |"

  # Generate the markdown separator line
  separator="|"
  for _ in "${COLUMNS[@]}"; do
    separator+=" --- |"
  done

  {
    echo "$formatted"
    echo "$separator"
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
      joined="\"$val\""
      val=$joined
    fi
    row+=("$val")
  done

  if [[ "$FORMAT" == "csv" ]]; then
    out="$(IFS=,; echo "${row[*]}")"
    echo "$out" >> "$OUTPUT"
  else
    printf "|%s|\n" "$(IFS='|'; echo "${row[*]}")" >> "$OUTPUT"
  fi

  done

fi

echo "✅ Done! Output saved to $OUTPUT"
