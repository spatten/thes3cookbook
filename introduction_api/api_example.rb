#!/usr/bin/env ruby

# require 'rubygems'
# require 's3_lib'
require File.join(File.dirname(__FILE__), 'lib/s3_lib')
include S3Lib

bucket_name = 'spattens_first_bucket'

# Delete the bucket if it already exists.  We want to start with an empty bucket.
Bucket.delete(bucket_name, :force => true) if Bucket.find(bucket_name)

# Create the bucket and store it in b
Bucket.create(bucket_name)
bucket = Bucket.find(bucket_name)
puts "Objects in bucket: #{bucket.objects.length}"

# Create some objects in the bucket
S3Object.create(bucket_name, 'first_object.txt', "this is the content")
S3Object.create(bucket_name, 'second_object.txt', "This is the second object")

# Create an object from a file
File.open('powers.txt', 'w') do |f|
  10.times do |n|
    f.puts "#{n},#{n**2},#{n**3},#{n**4}"
  end
end
S3Object.create(bucket_name, 'powers.txt', File.read('powers.txt'))

# Look at the objects in the bucket, using refresh to make sure we see the new objects.
puts "Objects in buckets: #{bucket.objects(:refresh => true).length}"
first_obj = bucket.objects.first
puts "contents of the first object (#{first_obj.key}): #{first_obj.value}"

# Accessing objects by their name
puts "contents of the 'powers.txt' object:\n#{bucket['powers.txt'].value}"

# Show the permissions on 'powers.txt'
puts "Grants on 'powers.txt':\n#{bucket['powers.txt'].acl.inspect}"

# Grant world-read permission on 'powers.txt'
bucket['powers.txt'].acl.add_grant!(:read, :type => :public)

# Show the new permissions on 'powers.txt'
puts "Grants on 'powers.txt':\n#{bucket['powers.txt'].acl.inspect}"