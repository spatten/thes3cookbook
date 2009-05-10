def self.object_request(verb, url, options = {})
    begin
      options.delete(:lazy_load)
      response = S3Lib.request(verb, url, options)
    rescue S3Lib::S3ResponseError => error
      case error.amazon_error_type
      when 'NoSuchBucket'
        raise S3Lib::BucketNotFoundError.new(
          "The bucket '#{bucket}' does not exist.",
          error.io, error.s3requester)
      when 'NotSignedUp'
        raise S3Lib::NotYourBucketError.new(
          "The bucket '#{bucket}' is owned by somebody else", 
          error.io, error.s3requester)
      when 'AccessDenied'
        raise S3Lib::NotYourBucketError.new(
          "The bucket '#{bucket}' is owned by someone else.", 
          error.io, error.s3requester)
      when 'MissingContentLength'
        raise S3Lib::NoContentError.new(
          "You must provide a value to put in the object.\nUsage: " + 
          "S3Lib::S3Object.create(bucket, key, value, options)", 
          error.io, error.s3requester)          
      else # Re-raise the error if it's not one of the above
        raise
      end
    end
    response
  end