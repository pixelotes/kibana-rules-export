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


