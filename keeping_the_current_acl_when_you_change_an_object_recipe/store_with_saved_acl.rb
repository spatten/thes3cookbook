class AWS::S3::S3Object
  
  def self.store_with_saved_acl(key, data, bucket = nil, params = {})
    acl = S3Object.acl(key, bucket)
    response = S3Object.store(key, data, bucket, params)
    S3Object.acl(key, bucket, acl)
    response
  end
  
end