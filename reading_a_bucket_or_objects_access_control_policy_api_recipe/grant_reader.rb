#!/usr/bin/env ruby
require File.join(File.dirname(__FILE__), 's3_authenticator')
require File.join(File.dirname(__FILE__), 's3_errors')
require File.join(File.dirname(__FILE__), 'acl')
require File.join(File.dirname(__FILE__), 'grant')
require 'rexml/document'

url = ARGV[0]
acl = S3Lib::Acl.new(url)
puts "Grants for #{url}"
acl.grants.each do |grant|
  puts "#{grant.permission}, #{grant.grantee} (#{grant.type})"
end