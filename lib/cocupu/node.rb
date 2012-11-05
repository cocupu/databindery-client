module Cocupu
  class Node
    attr_accessor :values, :conn
    def initialize(values)
      self.conn = Thread.current[:cocupu_connection] 
      self.values = values
    end

    def model_id
      values['model_id']
    end

    def identity
      values['identity']
    end

    def pool
      values['pool']
    end

    def url
      values['url'] || "/#{identity}/#{pool}/nodes"
    end

    def url=(url)
      values['url'] = url
    end

    def persistent_id=(id)
      values['persistent_id'] = id
    end

    def associations=(associations)
      values['associations'] = associations
    end

    def persistent_id
      values['persistent_id']
    end

    def save
      response = if persistent_id
        conn.put("#{url}.json", body: {node: values})
      else
        conn.post("#{url}.json", body: {node: values})
      end
      raise "Error saving models: #{response.inspect}" unless response.code >= 200 and response.code < 300
      if (response['persistent_id'])
        self.persistent_id = response['persistent_id']
        self.url = response['url']
      end
      values
    end

  end

end
