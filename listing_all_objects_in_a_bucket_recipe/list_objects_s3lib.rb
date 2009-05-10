#!/usr/bin/env ruby

require 'rubygems'
require 's3lib'
require 'rexml/document'

bucket = ARGV[0]

response = S3Lib.request(:get, bucket)
doc = REXML::Document.new(response).root

names = REXML::XPath.match(doc, '//Contents').collect do |object|
  "#{object.elements['Size'].text}\t\t#{object.elements['Key'].text}"
end

puts names.join("\n")