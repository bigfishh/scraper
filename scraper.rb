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
            title = char_element.css('h2 a')[0].attributes["title"].value.gsub(/\n/, "")
            link = "https://indeed.com" + char_element.css('h2 a')[0].attributes["href"].value.gsub(/\n/, "")
            description = char_element.css('div.summary').text.gsub(/\n/, "")
            company = description = char_element.css('span.company').text.gsub(/\n/, "")
            location = char_element.css('div.location').text.gsub(/\n/, "")
            salary = char_element.css('div.salarySnippet').text.gsub(/\n/, "")
            requirements = char_element.css('div.jobCardReqContainer').text.gsub(/\n/, "")
            # job = [title, link, description, company, location, salary, requirements]
            job = {title: title, link: link, description: description, company: company, location: location, salary: salary, requirements: requirements}

            @@jobs << job if !@@jobs.include?(job)
        end  
    end

    def parse(response, url:, data: {})

        10.times do
            scrape_page

            if browser.current_response.css('div#popover-background') || browser.current_response.css('div#popover-input-locationtst')
                browser.refresh 
            end
                    
            browser.find('/html/body/table[2]/tbody/tr/td/table/tbody/tr/td[1]/nav/div/ul/li[6]/a/span').click
            puts "🔹 🔹 🔹 CURRENT NUMBER OF JOBS: #{@@jobs.count}🔹 🔹 🔹"
            puts "🔺 🔺 🔺 🔺 🔺  CLICKED NEXT BUTTON 🔺 🔺 🔺 🔺 "
        end

        CSV.open('jobs.csv', "w") do |csv|
            csv << @@jobs
        end

        File.open("jobs.json","w") do |f|
            f.write(JSON.pretty_generate(@@jobs))
        end
        
        @@jobs
    end
end

jobs = JobScraper.crawl!
