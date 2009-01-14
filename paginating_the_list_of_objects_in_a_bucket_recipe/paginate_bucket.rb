#!/usr/bin/env ruby

require 'rubygems'
require 'aws/s3'
include AWS::S3

USAGE = "Usage: paginate_bucket <bucket_name> <number of objects per page>"
(puts USAGE; exit 0) unless ARGV.length == 2

bucket_name, num_per_page = ARGV

AWS::S3::Base.establish_connection!(
    :access_key_id     => ENV['AMAZON_ACCESS_KEY_ID'],
    :secret_access_key => ENV['AMAZON_SECRET_ACCESS_KEY']
)

files = []
marker = ''
loop do
  bucket = Bucket.find(bucket_name, :max_keys => num_per_page, :marker => marker)
  files += [bucket.objects.collect {|obj| obj.key}]
  marker = bucket.objects.last.key
  break unless bucket.is_truncated
end

puts files.inspect