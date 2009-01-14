module S3Lib
  
  class Acl
    
    attr_reader :xml, :url
  
    def initialize(url)
      @url = url.sub(/\/\Z/,'').sub(/\?acl/, '') + '?acl'
    end
        
    def grants
      @grants || get_grants
    end
    
    private 
    
    def get_grants
      response = Acl.acl_request(:get, @url)
      @xml = REXML::Document.new(response).root
      @grants = REXML::XPath.match(@xml, '//Grant').collect do |grant|
        grantee = grant.elements['Grantee']
        permission = grant.elements['Permission'].text
        S3Lib::Grant.new(permission, grantee)
      end
    end    
    
    def self.acl_request(verb, url, options = {})
      begin
        response = S3Lib.request(verb, url, options)
      rescue S3Lib::S3ResponseError => error
        puts "Error of type #{error.amazon_error_type}"
        case error.amazon_error_type
        when 'NoSuchBucket': raise S3Lib::BucketNotFoundError.new("The bucket '#{bucket}' does not exist.", error.io, error.s3requester)
        when 'NotSignedUp': raise S3Lib::NotYourBucketError.new("The bucket '#{bucket}' is owned by somebody else", error.io, error.s3requester)
        when 'AccessDenied': raise S3Lib::NotYourBucketError.new("The bucket '#{bucket}' is owned by someone else.", error.io, error.s3requester)
        when 'MalformedACLError': raise S3Lib::MalformedACLError.new("Your ACL was malformed.", error.io, error.s3requester)
        else # Re-raise the error if it's not one of the above
          raise
        end
      end
      response
    end    
  
  end
  
end
