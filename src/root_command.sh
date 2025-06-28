#!/usr/bin/env bash

KIBANA_URL=${args[--url]:-"https://localhost:5601"}
USERNAME=${args[--username]:-"elastic"}
PASSWORD=${args[--password]:-"changeme"}
FORMAT=${args[--format]:-"csv"}
PAGE_SIZE=${args[--page_size]:-"1000"}
SKIP_TLS=${args[--insecure]}

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
echo "📡 Fetching enabled rules from $KIBANA_URL ..."

if [[ "$SKIP_TLS" == "1" ]] || [[ -n "$SKIP_TLS" ]]; then
  # Add --insecure flag to curl commands
  response=$(curl -s -k -u "$USERNAME:$PASSWORD" \
  -H "kbn-xsrf: true" \
  --insecure \
  "$KIBANA_URL/api/detection_engine/rules/_find?filter=alert.attributes.enabled:true&per_page=$PAGE_SIZE")
else
  response=$(curl -s -k -u "$USERNAME:$PASSWORD" \
  -H "kbn-xsrf: true" \
  "$KIBANA_URL/api/detection_engine/rules/_find?filter=alert.attributes.enabled:true&per_page=$PAGE_SIZE")
fi

# Exit if the response doesn't contain data
if ! echo "$response" | jq -e '.data' > /dev/null 2>&1; then
    echo "❌ Failed to fetch rules from Kibana or invalid response format"
    echo "Response: $response"
    exit 1
else
    LINES=$(echo "$response" | jq | wc -l)
    echo "🔍 The response format looks correct and contains $LINES lines"
fi

# Parse and export
echo "🔧 Processing the response..."
if [ "$FORMAT" == "json" ]; then
    echo $response | jq > "$OUTPUT"
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
      name=$(echo "$name" | sed 's/"/""/g')
      desc=$(echo "$desc" | sed 's/"/""/g')
      tags=$(echo "$tags" | sed 's/"/""/g')
      query=$(echo "$query" | sed 's/"/""/g')
      echo "\"$name\",\"$desc\",\"$tags\",\"$query\"" >> "$OUTPUT"
    else
      echo "| $name | $desc | $tags | \`$query\` |" >> "$OUTPUT"
    fi
  done
fi

echo "✅ Done! Output saved to $OUTPUT"
