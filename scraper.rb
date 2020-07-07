require 'open-uri'
require 'nokogiri'
require 'pry'

html = open("https://en.wikipedia.org/wiki/Avatar:_The_Last_Airbender")

response = Nokogiri::HTML(html)

description = response.css("p").text.strip.split("\n")[0]

picture = response.css("td a img").find{|picture| picture.attributes["alt"].value.include?("Avatar The Last Airbender logo.svg")}.attributes["src"].value


binding.pry 

puts "hello"