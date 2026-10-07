import requests

# Take input from the user for the product name they want to search for
search_term = input("Enter a product name: ")

url = "https://mdcomputers.in/"

params = {
    "route": "product/search",
    "search": search_term
}

# Make a GET request to the website with the search term as a parameter
try:
    response = requests.get(url, params=params, timeout=60)
    response.raise_for_status()
except requests.exceptions.RequestException as error:
    print("Error while requesting the webpage:", error)
    exit()
    
# Check if the request was successful (status code 200)
print("Status Code:", response.status_code)
print("Search URL:", response.url)

# Print the first 500 characters of the response content to verify the request was successful
print("\nWebpage Content:")
print(response.text[:500])

from bs4 import BeautifulSoup

# Create a BeautifulSoup object to parse the HTML content of the response
soup = BeautifulSoup(response.text, 'html.parser')

# Find all product containers on the page
products = soup.find_all('div', class_='product-wrapper')

print("Total Product containers:", len(products))
print("Products found:")
for product in products:
    # Find the product heading
    heading = product.find("h3")
    if heading:
        # Find the product link within the heading
        link = heading.find("a")
        if link:
            product_url = link.get("href")
            # Check if it is a valid product link
            if product_url and "/product/" in product_url:
                # Extract the product name
                product_name = link.get_text(strip=True)
                # Find the product price
                price_tag = product.find("span", class_="amount")

                if price_tag:
                    price = price_tag.get_text(strip=True)
                else:
                    price = "Price not found"

                # Print the product name, price, and URL
                print("Name:", product_name)
                print("Price:", price)
                print("URL:", product_url)
                print("-" * 40)