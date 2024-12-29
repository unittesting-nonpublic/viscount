import requests
from bs4 import BeautifulSoup
import csv

# Function to crawl GitHub links
def crawl_github_links(name, url):
    response = requests.get(url)
    soup = BeautifulSoup(response.content, 'html.parser')
    meta_tags = soup.find_all("meta", attrs={"property": "og:url"})
    print(name + "," + url + "," + meta_tags[0]["content"].split('/')[len(meta_tags[0]["content"].split('/'))-1])

# Example usage
with open('/home/firhard/Desktop/test-visibility-checker/apache_projects.csv', 'r') as file:
    reader = csv.reader(file)
    for row in reader:
        # print(row[1])
        crawl_github_links(row[0], row[1] + "/commit")