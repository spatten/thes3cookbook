  def value=(value)
  S3Object.create(@bucket, @key, value, @options)
  @value = value
  refresh_metadata
end