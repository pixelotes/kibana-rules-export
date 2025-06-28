# kibana-rules-export

Command-line tool to export enabled detection rules from Kibana to CSV or Markdown format using the Detection Engine API.

## Features

- Connects to a Kibana instance
- Retrieves all enabled detection rules
- Outputs a table with: Name, Description, Tags, Query
- Supports output in CSV or Markdown format

## Requirements

- Bash
- curl
- [jq](https://stedolan.github.io/jq/)
- [bashly](https://bashly.dannyb.co/install) (if you want to build it yourself)

## Building the script

### Setup

```bash
gem install bashly
```

### Build
```bash
bashly generate
```

## Usage
```bash
./kibana-rules-export --username USER --password PASS [--url URL] [--page_size PAGE_SIZE] [--format csv|markdown]
```

### Options
- --username (required): Kibana username
- --password (required): Kibana password
- --url (optional): Kibana base URL (default: http://localhost:5601)
- --page_size (optional): Number of results returned per page (default: 1000)
- --format (optional): Output format (csv or markdown, default: csv)
- --insecure (optional): Skips TLS verification

### Output
rules.csv or rules.md will be created in the current directory.
