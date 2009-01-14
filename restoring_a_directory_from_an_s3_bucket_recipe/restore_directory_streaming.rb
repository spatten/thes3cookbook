#!/usr/bin/env ruby

require 'fileutils'
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

b = Bucket.find(bucket)

b.objects.each do |object|
  local_file = File.join(root, object.key)
  puts "#{bucket}:#{object.key} ==> #{local_file}"
  FileUtils.mkdir_p(File.dirname(local_file))
  
  File.open(local_file, 'w') do |file|
    S3Object.stream(object.key, bucket) do |chunk|
      file.write chunk
    end
  end
end