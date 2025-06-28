# kibana-rules-export

Export enabled detection rules from Kibana to CSV or Markdown

| Attributes       | &nbsp;
|------------------|-------------
| Version:         | 1.0

## Usage

```bash
kibana-rules-export [OPTIONS]
```

## Dependencies

#### *jq*



#### *curl*



#### *bash*



## Options

#### *--username USERNAME*

Kibana username

| Attributes      | &nbsp;
|-----------------|-------------
| Required:       | ✓ Yes

#### *--password PASSWORD*

Kibana password

| Attributes      | &nbsp;
|-----------------|-------------
| Required:       | ✓ Yes

#### *--url URL*

Kibana base URL

| Attributes      | &nbsp;
|-----------------|-------------
| Default Value:  | http://localhost:5601

#### *--page_size PAGE_SIZE*

Number of results returned per page

| Attributes      | &nbsp;
|-----------------|-------------
| Default Value:  | 1000

#### *--format FORMAT*

Output format (csv, markdown or json)

| Attributes      | &nbsp;
|-----------------|-------------
| Default Value:  | csv
| Allowed Values: | csv, markdown, json

#### *--insecure*

Skip SSL certificate verification

Command-line tool to export enabled detection rules from Kibana to CSV or Markdown format using the Detection Engine API.

## Features

- Connects to a Kibana instance
- Retrieves all enabled detection rules
- Outputs a table with: Name, Description, Tags, Query
- Supports output in CSV or Markdown format

## Building the script manually

### Setup

******bash
gem install bashly
******

### Build
******bash
bashly generate
******

## Usage
******bash
./kibana-rules-export --username USER --password PASS [--url URL] [--page_size PAGE_SIZE] [--format csv|markdown] [--insecure]
******

