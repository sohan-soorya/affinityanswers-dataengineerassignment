# Affinity Answers - Data Engineer Intern Assignment

This repository contains my solutions for the Python, SQL/Database, and Unix Shell Scripting questions in the take-home assignment.

## Repository Structure

- `question1.py` - Accepts a search term, requests the MD Computers search-results page, parses the HTML with BeautifulSoup, and prints the listed product information.
- `question2.sql` - Contains three SQL queries for the public Rfam database.
- `question3.sh` - Accepts a CSV URL, downloads the data, extracts the company name, location, and founding year, and sorts the output by founding year.
- `requirements.txt` - Contains the Python dependencies for `question1.py`.

## Prerequisites

- Python 3
- pip
- MySQL command-line client
- Bash or another Unix-like environment
- curl
- GNU awk (`gawk`)

On Windows, Question 3 was tested using Ubuntu through WSL. WSL is not required if Bash, curl, and GNU awk are already available on Linux, macOS, or another Unix-like environment.

## Question 1 - Python Web Scraping

Install the Python dependencies:

```bash
python -m pip install -r requirements.txt
```

Run the program:

```bash
python question1.py
```

The program works as follows:

1. The user enters a product search term.
2. `requests` sends an HTTP GET request to MD Computers.
3. The search query is passed using the `params` argument.
4. BeautifulSoup parses the returned HTML.
5. Product containers are identified from the page structure.
6. The product name, price, and URL are extracted and displayed.

The scraper depends on the current HTML structure of the MD Computers website. It may need changes if the website structure changes.

### Output Format

I chose to print the product information directly in the terminal because the assignment allows any output format, and the result only contains a few fields for each product. This kept the program simple and made it easy to verify the extracted values while testing.

## Question 2 - SQL and Databases

The queries use the public Rfam MySQL database. Connect using:

```bash
mysql --host=mysql-rfam-public.ebi.ac.uk --port=4497 --user=rfamro --database=Rfam --protocol=TCP
```

No password was required for this public read-only account.

After connecting, run the SQL file from the MySQL command-line client:

```sql
SOURCE question2.sql;
```

The file answers these three questions:

1. **Acacia:** Filters taxonomy species names beginning with `Acacia ` and counts the matching records. The verified result was 326 records.
2. **Wheat:** Joins `taxonomy` and `rfamseq` using `ncbi_id`, filters Triticum DNA records, sorts by sequence length in descending order, and selects the longest sequence. The verified result was *Triticum durum* (durum wheat), with a length of 836514780 and molecule type `genomic DNA`.
3. **Family pagination:** Joins `family`, `full_region`, and `rfamseq`, groups the rows by family, finds the maximum sequence length, filters long DNA sequences, and sorts them in descending order. It uses `LIMIT 15 OFFSET 120` because `(page 9 - 1) * 15 = 120`. The complete query returned 15 rows for page 9.

### Execution Note

The SQL queries were first tested using MySQL Workbench. The first two queries ran successfully. The third query repeatedly failed with MySQL Error 2013 because Workbench lost the connection while waiting for the long-running query.

The Workbench read timeout was increased from 30 seconds to 120 seconds, but the query still took longer. Smaller family ranges were tested and confirmed that the joins and aggregation were working. The same complete query was then run using the MySQL command-line client. It completed successfully, returned the required 15 rows, and took approximately 7 minutes 57 seconds.

## Question 3 - Unix Shell Scripting

The script accepts the CSV URL as its first command-line argument. Make it executable and run it with the assignment URL:

```bash
chmod +x question3.sh
./question3.sh "https://raw.githubusercontent.com/datasets/s-and-p-500-companies/refs/heads/main/data/constituents.csv"
```

The script:

1. Reads the URL from the first argument.
2. Checks that a URL was supplied.
3. Downloads the CSV using curl.
4. Passes the CSV into GNU awk.
5. Uses an `FPAT` pattern so quoted CSV fields containing commas are treated as one field.
6. Extracts `Security` as Company Name, `Headquarters Location` as Location, and `Founded` as Founding Year.
7. Extracts the first four-digit year from values such as `2013 (1888)`.
8. Sorts the results numerically by founding year.

A simple `cut -d','` command or a basic comma-separated awk approach was avoided because locations such as `"Saint Paul, Minnesota"` contain commas inside quoted CSV fields.

## Design Notes

- Requests and BeautifulSoup were used for Question 1 because the required product data was available in the returned HTML, so browser automation was not needed.
- The SQL queries were written after inspecting the Rfam table structures and relationships.
- The MySQL command-line client was used for the long-running SQL query after MySQL Workbench's configured read timeout was too short.
- GNU awk was used for the shell task because the CSV contains quoted fields with embedded commas.

## Execution

- Run `question1.py` and enter a sample search term.
- Execute `question2.sql` through the MySQL command-line client.
- Run `question3.sh` with the provided CSV URL.
