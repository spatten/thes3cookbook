require 'csv'

# Take an Amazon S3 log line and break it into its components.
# A log line looks like this, without the line breaks:
# 9d92623ba6dd9d7cc06a7b8bcc46381e7c646f72d769214012f7e91b50c0de0f 
# assets0.plotomatic.com [18/Aug/2008:21:34:36 +0000] 
# 24.108.34.11 65a011a29cdf8ec533ec3d1ccaae921c A057F70AB86684FA 
# REST.GET.OBJECT images/slideshow/cu_vs_e.png 
# "GET /images/slideshow/cu_vs_e.png?1201047084 HTTP/1.1" 200 - 
# 14756 14756 112 106 "http://www.plotomatic.com/" 
# "Mozilla/5.0 (Macintosh; U; Intel Mac OS X 10.5; en-US; rv:1.9.0.1) 
#  Gecko/2008070206 Firefox/3.0.1"
class LogLine
  ANONYMOUS_CANONICAL_ID = '65a011a29cdf8ec533ec3d1ccaae921c'

  FIELDS = [:bucket_owner, :bucket_name, :time, :remote_ip, :requestor, 
            :request_id, :operation, :key, :uri, :status, :error_code, 
            :bytes_sent, :object_size, :total_time, :turn_around_time, 
            :referrer, :user_agent]  
   
  attr_reader *(FIELDS + [:line])
  
  def initialize(line)
    # If you turn the square brackets around the time into double quotes,
    # then the line can be easily parsed as a space delimited CSV file.
    # This ugly regular expression finds the time surrounded by 
    # square brackets
    # the .sub then replaces the square brackets with double quotes
    @line = line.sub(
      /\[(\d\d\/[A-Z][a-z][a-z]\/\d\d\d\d:\d\d:\d\d:\d\d \+0000)\]/, '"\1"')
    parsed_line = CSV.parse_line(@line, ' ')
    
    # Set an instance variable for each field in FIELDS
    parsed_line.each_with_index do |field, n|
      # nil values are represented as '-' in the line, 
      # so turn them back in to nils
      field = nil if field == '-' 
      instance_variable_set("@#{FIELDS[n]}", field)
    end
    @requestor = :anonymous if @requestor == ANONYMOUS_CANONICAL_ID
    
    # Time is of the form "18/Aug/2008:21:34:36 +0000"
    # split the time into its components, and then create a 
    # GMT Time instance with the values.
    day, month, year, hour, minute, second, offset = @time.split(/[\/|:| ]/)
    @time = Time.utc(year, month, day, hour, minute, second)
  end
  
  def anonymous_get?
    @operation == 'REST.GET.OBJECT' && @requestor == :anonymous
  end
  
end