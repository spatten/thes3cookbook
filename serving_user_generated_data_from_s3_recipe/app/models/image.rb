class Image < ActiveRecord::Base
  
  LOCAL_DIRECTORY = 'user_generated'
  BUCKET = 'asynchronous_migration'
  
  def url
    is_on_s3 ? s3_url : local_url
  end
  
  def upload_to_s3
    AWS::S3::S3Object.store(name, File.open(full_local_url), BUCKET, 
                            :access => :public_read)
    update_attribute(:is_on_s3, true)
  end
  
  private
  
  def full_local_url
    File.join(RAILS_ROOT, 'public', 'images', local_url)
  end
  
  def local_url
    File.join(LOCAL_DIRECTORY, name)
  end
  
  def s3_url
    File.join('http://s3.amazonaws.com/', BUCKET, name)
  end
end
