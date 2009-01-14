#!/usr/bin/env ruby

require 'rexml/document'

xml = <<XML
<?xml version=\"1.0\" encoding=\"UTF-8\"?>
<ListAllMyBucketsResult xmlns=\"http://s3.amazonaws.com/doc/2006-03-01/\">
  <Owner>
    <ID>9d92623ba6dd9d7cc06a7b8bcc46381e7c646f72d769214012f7e91b50c0de0f</ID>
    <DisplayName>scottpatten</DisplayName>
  </Owner>
  <Buckets>
    <Bucket>
      <Name>amazon_s3_and_ec2_cookbook</Name>
      <CreationDate>2008-08-03T22:41:56.000Z</CreationDate>
    </Bucket>
    <Bucket>
      <Name>spatten_music</Name>
      <CreationDate>2008-02-19T22:07:24.000Z</CreationDate>
    </Bucket>
    <Bucket>
      <Name>assets.plotomatic.com</Name>
      <CreationDate>2007-11-05T23:34:56.000Z</CreationDate>
    </Bucket>
  </Buckets>
</ListAllMyBucketsResult>
XML

doc = REXML::Document.new(xml).root
buckets = REXML::XPath.match(doc, '/ListAllMyBucketsResult/Buckets/Bucket')
puts "Creation Date\t\t\tName"
buckets.each do |bucket|
  puts "#{bucket.elements['CreationDate'].text}\t#{bucket.elements['Name'].text}"
end
