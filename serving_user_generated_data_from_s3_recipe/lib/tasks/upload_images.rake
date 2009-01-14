require 'aws/s3'

task :connect_to_s3 do
  AWS::S3::Base.establish_connection!(
      :access_key_id     => ENV['AMAZON_ACCESS_KEY_ID'],
      :secret_access_key => ENV['AMAZON_SECRET_ACCESS_KEY']
  )
end 

task :upload_images => [:environment, :connect_to_s3] do
  AWS::S3::Bucket.create(Image::BUCKET)
  Image.find_all_by_is_on_s3(false).each do |image|
    image.upload_to_s3
  end
end

