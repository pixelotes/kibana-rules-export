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


# Output file based on format
if [[ "$FORMAT" == "csv" ]]; then
  OUTPUT="rules.csv"
  echo "\"Name\",\"Description\",\"Tags\",\"Query\"" > "$OUTPUT"
elif [ "$FORMAT" == "json" ]; then
  OUTPUT="rules.json"
else
  OUTPUT="rules.md"
  {
    echo "| Name | Description | Tags | Query |"
    echo "|------|-------------|------|-------|"
  } > "$OUTPUT"
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

# Parse and export
echo "🔧 Processing the response..."
if [ "$FORMAT" == "json" ]; then
    echo "$response" | jq > "$OUTPUT"
else
  echo "$response" | jq -r '
    .data[]
    | [
        .name,
        .description,
        (.tags | join(", ")),
        .query
      ]
    | @tsv
  ' | while IFS=$'\t' read -r name desc tags query; do
    name="${name//|/\\|}"
    desc=$(echo "$desc" | tr '\n' ' ' | sed 's/|/\\|/g')
    tags="${tags//|/\\|}"
    query=$(echo "$query" | tr '\n' ' ' | sed 's/|/\\|/g')

    [[ ${#query} -gt 200 ]] && query="${query:0:200}…"

    if [[ "$FORMAT" == "csv" ]]; then
      #name=$(echo "$name" | sed 's/"/""/g')
      #desc=$(echo "$desc" | sed 's/"/""/g')
      #tags=$(echo "$tags" | sed 's/"/""/g')
      #query=$(echo "$query" | sed 's/"/""/g')
      name=${name//\"/\"\"}
      desc=${desc//\"/\"\"}
      tags=${tags//\"/\"\"}
      query=${query//\"/\"\"}
      echo "\"$name\",\"$desc\",\"$tags\",\"$query\"" >> "$OUTPUT"
    else
      echo "| $name | $desc | $tags | \`$query\` |" >> "$OUTPUT"
    fi
  done
fi

echo "✅ Done! Output saved to $OUTPUT"
