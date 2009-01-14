  def initialize(line)
    # If you turn the square brackets around the time into double quotes,
    # then the line can be easily parsed as a space delimited CSV file
    # This ugly regular expression finds the time surrounded by square brackets
    # the .sub then replaces the square brackets with double quotes
    @line = line.sub(/\[(\d\d\/[A-Z][a-z][a-z]\/\d\d\d\d:\d\d:\d\d:\d\d \+0000)\]/, '"\1"')
    parsed_line = CSV.parse_line(@line, ' ')
    
    @bucket_owner = parsed_line[0]
    @bucket_name = parsed_line[1]
    @time = parsed_line[2]
    @remote_ip = parsed_line[3]
    @requestor = parsed_line[4]
    ....