module Cocupu
  class Pool
    attr_accessor :values, :conn
    def initialize(values, conn)
      self.conn = conn
      self.values = values
    end
    def short_name
      values["short_name"]
    end

    def url
      values["url"]
    end

    def models
      return @models if @models
      # req_url = "http://#{host}:#{port}#{url}/models.json?auth_token=#{token}"
      # puts "Calling #{req_url}"
      response = conn.get("#{url}/models.json")
      #puts "RESP: #{response}"
      raise "Error getting models: #{response}" unless response.code == 200
      @pools = response.map {|val| Model.new(val)}
    end
  end
end
