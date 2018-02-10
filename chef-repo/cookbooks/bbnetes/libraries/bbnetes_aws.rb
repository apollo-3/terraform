require 'aws-sdk'

module BBnetes
  class AWS
    def initialize(aws_access_key,
                   aws_secret_key,
                   region,
                   node)
      @aws_access_key = aws_access_key
      @aws_secret_key    = aws_secret_key
      @region            = region
      @credentials       = Aws::Credentials.new(@aws_access_key,
                                                @aws_secret_key)
      @node              = node
    end
  end
end