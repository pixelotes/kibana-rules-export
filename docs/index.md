# kibana-rules-export

Command-line tool to export enabled detection rules from Kibana to JSON, CSV or Markdown format using the Detection Engine KiAPI.

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

## Building the script manually

### Setup

~~~bash
gem install bashly
~~~

### Build
~~~bash
bashly generate
~~~

## Output
rules.json, rules.csv or rules.md will be created in the current directory.

