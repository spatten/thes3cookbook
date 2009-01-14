# service.rb
require File.join(File.dirname(__FILE__), 's3_authenticator')
require 'rexml/document'

module S3Lib
  
  class Service
    
    def self.buckets
      response = S3Lib.request(:get, '')
      xml = REXML::Document.new(response).root

      REXML::XPath.match(xml, '//Buckets/Bucket').collect do |bucket_xml|
        Bucket.new(bucket_xml)
      end
    end
        
  end
  
  # This is a stub of the Bucket class that will be replaced with
  # a full-blown class in the following recipes.
  class Bucket

    attr_reader :name
    
    def initialize(doc)
      @name = doc.elements['Name'].text      
    end
    
  end
  
end

if __FILE__ == $0
  S3Lib::Service.buckets
end