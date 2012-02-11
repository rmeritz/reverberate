#!/usr/bin/env ruby

require 'rubygems'
require 'nokogiri'
require 'open-uri'
require 'net/http'

verb = ARGV.first

uri = URI('http://tyda.se/search/'+verb)
html = Net::HTTP.get(uri)

puts html
puts uri
