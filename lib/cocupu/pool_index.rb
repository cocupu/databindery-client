module Cocupu
  class PoolIndex

    # @option [String] pool_id required
    # @option [String] index_name required
    def self.update(options={})
      raise ArgumentError, 'You must provide a pool_id' unless options[:pool_id]
      raise ArgumentError, 'You must provide an index_name' unless options[:index_name]
      conn = Thread.current[:cocupu_connection]
      index_url = "/pools/#{options[:pool_id]}/indices/#{options[:index_name]}"
      request_params = {}
      request_params[:source] = options[:source] if options.has_key?(:source)
      conn.put("#{index_url}.json", body: request_params)
    end

  end
end
