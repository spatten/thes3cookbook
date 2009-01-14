module S3Lib
  
  class Acl
    
    attr_reader :xml, :parent, :url
  
    def initialize(parent_or_url)
      if parent_or_url.respond_to?(:url)
        @parent = parent_or_url
        @url = @parent.url.sub(/\/\Z/,'') + '?acl'
      else
        @url = parent_or_url.sub(/\/\Z/,'').sub(/\?acl/, '') + '?acl'
      end
    end
        
    def grants(params = {})
      refresh_grants if params[:refresh]
      @grants || get_grants
    end
    
    def clear_grants
      @grants = []
      set_grants
    end
    
    # permission must be one of :read, :write, :read_acl, :write_acl or :full_control
    # The grantee Hash should look like this:
    # {:type => :canonical|:email|:all_s3|:public, 
    #  :grantee => canonical_user_id | email_address}
    #
    # The :grantee element of the hash is only required (and meaningful) 
    # for :canonical and :email Grants    
    def add_grant(permission, grantee)
      grants.push(S3Lib::Grant.new(permission, grantee))      
    end
        
    # Add a grant and PUT it to the server right away
    def add_grant!(permission, grantee)
      add_grant(permission, grantee)
      set_grants
    end    
    
    def remove_grant(grant_num)
      grants.delete_at(grant_num)
      refresh_grants
    end
    
    def refresh_grants
      get_grants
    end
    
    def set_grants
      Acl.acl_request(:put, @url, :body => to_xml)
      refresh_grants
    end
    
    def owner
      get_grants unless @xml
      @xml.elements['Owner'].elements['ID'].text
    end
    
    def to_xml
      builder = Builder::XmlMarkup.new(:indent => 2)
      xml = builder.AccessControlPolicy('xmlns' => 'http://s3.amazonaws.com/doc/2006-03-01/') do
        builder.Owner do
          builder.ID(owner)
        end
        builder.AccessControlList do
          grants.each do |grant|
            builder << grant.to_xml
          end
        end
      end
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
        if verb == :put
          options = {'content-type' => 'text/xml'}.merge(options) # Make sure content-type is set for :put
        end
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
