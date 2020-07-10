require 'csv'
require 'nokogiri'
require 'open-uri'
require 'pry'
require 'kimurai'


html = open("https://en.wikipedia.org/wiki/Avatar:_The_Last_Airbender")
response = Nokogiri::HTML(html)

data_arr = []

description = response.css("p").text.strip.split("\n")[0]
picture = response.css("td a img").find{|picture| picture.attributes["alt"].value.include?("Avatar The Last Airbender logo.svg")}.attributes["src"].value

data_arr.push([description, picture])

CSV.open('data.csv', "w") do |csv|
    csv << data_arr
end

# # --------------------------- Static Page Scraping ---------------------------------------------------------------------->
class JobScraper < Kimurai::Base

  @name= 'eng_job_scraper'
  @start_urls = ["https://www.indeed.com/jobs?q=software+engineer&l=New+York%2C+NY"]
  @engine = :selenium_chrome

  @@jobs = []

  def scrape_page
    doc = browser.current_response
    returned_jobs = doc.css('td#resultsCol')
    returned_jobs.css('div.jobsearch-SerpJobCard').each do |char_element|
      # scraping individual listings 
      title = char_element.css('h2 a')[0].attributes["title"].value.gsub(/\n/, "")
      link = "https://indeed.com" + char_element.css('h2 a')[0].attributes["href"].value.gsub(/\n/, "")
      description = char_element.css('div.summary').text.gsub(/\n/, "")
      company = description = char_element.css('span.company').text.gsub(/\n/, "")
      location = char_element.css('div.location').text.gsub(/\n/, "")
      salary = char_element.css('div.salarySnippet').text.gsub(/\n/, "")
      requirements = char_element.css('div.jobCardReqContainer').text.gsub(/\n/, "")

      # creating a job object
      job = {title: title, link: link, description: description, company: company, location: location, salary: salary, requirements: requirements}

      # adding the object if it is unique
      @@jobs << job if !@@jobs.include?(job)
    end
  end

  def parse(response, url:, data: {})
     # scrape first page
     scrape_page

     # next page link starts with 20 so the counter will be initially set to 2
     num = 2
 
     # visit next page and scrape it
     10.times do
         browser.visit("https://www.indeed.com/jobs?q=software+engineer&l=New+York,+NY&start=#{num}0")
         scrape_page
         num += 1
     end
 
     @@jobs

     CSV.open('jobs.csv', "w") do |csv|
        csv << @@jobs
    end
    
  end

end
