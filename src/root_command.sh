#!/usr/bin/env bash

KIBANA_URL="${args[url]}"
USERNAME="${args[username]}"
PASSWORD="${args[password]}"
FORMAT="${args[format]}"
PAGE_SIZE="${args[page_size]}"

# Output file based on format
if [[ "$FORMAT" == "csv" ]]; then
  OUTPUT="rules.csv"
  echo "\"Name\",\"Description\",\"Tags\",\"Query\"" > "$OUTPUT"
else
  OUTPUT="rules.md"
  {
    echo "| Name | Description | Tags | Query |"
    echo "|------|-------------|------|-------|"
  } > "$OUTPUT"
fi

# Fetch rules from Kibana
echo "📡 Fetching enabled rules from $KIBANA_URL ..."
response=$(curl -s -u "$USERNAME:$PASSWORD" \
  -H "kbn-xsrf: true" \
  "$KIBANA_URL/api/detection_engine/rules/_find?filter=alert.attributes.enabled:true&per_page=$PAGE_SIZE")

if [[ $? -ne 0 || -z "$response" ]]; then
  echo "❌ Failed to fetch rules from Kibana."
  exit 1
fi

# Parse and export
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

echo "✅ Done! Output saved to $OUTPUT"
