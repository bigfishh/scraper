require 'csv'
require 'open-uri'
require 'nokogiri'

html = open("https://en.wikipedia.org/wiki/Avatar:_The_Last_Airbender")
doc = Nokogiri::HTML(html)

data_arr = []

description = doc.css("p").text.strip.split("\n")[0]
picture = doc.css("td a img").find{|picture| picture.attributes["alt"].value.include?("Avatar The Last Airbender logo.svg")}.attributes["src"].value

data_arr.push([description, picture])

CSV.open('data.csv', "w") do |csv|
    csv << data_arr
end

