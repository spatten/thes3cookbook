#!/usr/bin/env ruby

require 'find'
require 'rubygems'
require 'aws/s3'
include AWS::S3

bucket = ARGV[0]
root = ARGV[1]
directory = ARGV[2] || '.'

AWS::S3::Base.establish_connection!(
    :access_key_id     => ENV['AMAZON_ACCESS_KEY_ID'],
    :secret_access_key => ENV['AMAZON_SECRET_ACCESS_KEY']
)

Bucket.create(bucket)

# Find all of the files to copy
files_to_copy = []
Find.find(directory) do |file|
  unless File.directory?(file) || File.symlink?(file)
    files_to_copy.push file
  end
end

# Upload the files to the bucket
files_to_copy.each do |file|
  # remove the root and a slash at the beginning if it exists
  key = file.sub(/\A#{root}/, '').sub(/\A\//, '') 
  puts "#{file} ==> #{bucket}:#{key}"
  S3Object.store(key, open(file), bucket)
end
  
