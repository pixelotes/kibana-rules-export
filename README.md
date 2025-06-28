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

#### *--username, -u USERNAME*

Kibana username

| Attributes      | &nbsp;
|-----------------|-------------
| Required:       | ✓ Yes

#### *--password, -p PASSWORD*

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

#### *--format, -f FORMAT*

Output format (csv, markdown or json)

| Attributes      | &nbsp;
|-----------------|-------------
| Default Value:  | csv
| Allowed Values: | csv, markdown, json

#### *--insecure, -i*

Skip SSL certificate verification

## Building the script manually

### Setup

First, install bashly to build the project (requires Ruby 2.6+)
~~~bash
gem install bashly
~~~

### Build
Once bashly is installed, compile the project.
~~~bash
bashly generate
~~~
There should be a new "kibana-rules-export" script as a result.
Try running it with:
~~~bash
./kibana-rules-export --help
~~~

## Output
rules.json, rules.csv or rules.md will be created in the current directory.

## License

This project is licensed under the [MIT License](./LICENSE). See the **LICENSE** file for full details.

