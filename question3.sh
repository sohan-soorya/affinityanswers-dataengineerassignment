#!/bin/bash

# Check if a URL was given
if [ -z "$1" ]; then
    echo "Usage: ./question3.sh <csv_url>"
    exit 1
fi

url="$1"

# Print column headings
echo -e "Company Name\tLocation\tFounding Year"

# Download the CSV, extract the required columns, and sort by founding year
curl -fsSL "$url" |
gawk '
BEGIN {
    FPAT = "([^,]*)|(\"([^\"]|\"\")*\")"
    OFS = "\t"
}

NR == 1 {
    next
}

{
    company = $2
    location = $5
    founded = $8

    # Remove surrounding quotes
    gsub(/^"|"$/, "", company)
    gsub(/^"|"$/, "", location)

    # Find the first 4-digit year
    if (match(founded, /[0-9]{4}/)) {
        year = substr(founded, RSTART, RLENGTH)

        print company, location, year
    }
}
' |
sort -t $'\t' -k3,3n