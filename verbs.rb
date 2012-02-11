#!/usr/bin/env ruby

require 'net/http'

uri = URI('http://tyda.se/search/f%C3%A5')
Net::HTTP.get_print(uri)
