# bucket.rb
module S3Lib
    
  class Bucket
    
    attr_reader :name, :xml, :prefix, :marker, :max_keys
    
    def self.create(name, params = {})
      # translate from :access to 'x-amz-acl'
      params['x-amz-acl'] = params.delete(:access) if params[:access]
      response = self.bucket_request(:put, name, params)
      response.status[0] == "200" ? true : false
    end
    
    # passing :force => true will cause the bucket to be deleted even 
    # if it is not empty.
    def self.delete(name, params = {})
      if params.delete(:force)
        self.delete_all(name, params)
      end
      response = self.bucket_request(:delete, name, params)
    end
    
    def delete(params = {})
      self.class.delete(@name, @params.merge(params))
    end
    
    def self.delete_all(name, params = {})
      bucket = Bucket.find(name, params)
      bucket.delete_all
    end
    
    def delete_all
      objects.each do |object|
        object.delete
      end
    end

    def self.find(name, params = {})
      response = self.bucket_request(:get, name, params)
      doc = REXML::Document.new(response)
      Bucket.new(doc, params)
    end
    
    def initialize(doc, params = {})
      @xml = doc.root
      @params = params
      @name = @xml.elements['Name'].text
      @max_keys = @xml.elements['MaxKeys'].text.to_i
      @prefix = @xml.elements['Prefix'].text
      @marker = @xml.elements['Marker'].text
    end
    
    def is_truncated?
      @xml.elements['IsTruncated'].text == 'true'
    end
    
    def objects(params = {})
      refresh if params[:refresh]
      @objects || get_objects
    end
        
    def refresh
      refreshed_bucket = Bucket.find(@name, @params)
      @xml = refreshed_bucket.xml
      @objects = nil
    end
    
    def refresh_acl
      get_acl
    end
    
    def url
      @name
    end
    
    # access an object in the bucket by key name
    def [](key)
      objects.detect{|object| object.key == key}
    end
    
    def acl(params = {})
      refresh_acl if params[:refresh]      
      @acl || get_acl
    end
    
    private
        
    def self.bucket_request(verb, name, params = {})
      begin
        response = S3Lib.request(verb, name, params)  
      rescue S3Lib::S3ResponseError => error
        case error.amazon_error_type
        when "NoSuchBucket"
          raise S3Lib::BucketNotFoundError.new(
            "The bucket '#{name}' does not exist.", 
            error.io, error.s3requester)
        when "NotSignedUp"
          raise S3Lib::NotYourBucketError.new(
            "The bucket '#{name}' is owned by someone else.", 
            error.io, error.s3requester)
        when "BucketNotEmpty"
          raise S3Lib::BucketNotEmptyError.new(
            "The bucket '#{name}' is not empty, so you can't delete it." + 
            "\nTry using Bucket.delete_all('#{name}') first, or " + 
            "Bucket.delete('#{name}', :force => true).", 
            error.io, error.s3requester)
        else # Re-raise the error if it's not one of the above
          raise
        end
      end
    end    
    
    def get_objects
      @objects = REXML::XPath.match(@xml, '//Contents').collect do |object|
        key = object.elements['Key'].text
        S3Lib::S3Object.new(self, key, :lazy_load => true)
      end
    end
    
    def get_acl
      @acl = Acl.new(self)
    end
    
  end
  
end