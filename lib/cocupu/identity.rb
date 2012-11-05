module Cocupu
  class Identity
    attr_accessor :values, :conn
    def initialize(values)
      self.conn = Thread.current[:cocupu_connection] 
      self.values = values
    end

    def short_name
      values["short_name"]
    end

    def url
      values["url"]
    end

    def pools
      return @pools if @pools
      response = conn.get(url+'.json')
      raise "Error getting pools: #{response}" unless response.code == 200
      @pools = response.map {|val| Pool.new(val, conn)}
    end

    def pool(short_name)
      pools.find{|i| i.short_name == short_name}
    end

  end

end
