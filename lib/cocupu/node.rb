module Cocupu
  class Node
    attr_accessor :values
    attr_reader :conn
    def initialize(values)
      @conn = Thread.current[:cocupu_connection] 
      self.values = values
    end
    
    # Find
    # @return Array of Cocupu::Nodes
    # @example
    #   Cocupu::Node.find{"my_identity", "pool_20", {'model_id' => 22} }
    def self.find(identity, pool, query_params)
      conn = Thread.current[:cocupu_connection]
      url = "/#{identity}/#{pool}/nodes/search.json"
      nodes_json = JSON.parse(conn.get(url,query_params).body)
      nodes = nodes_json.map {|json| Cocupu::Node.new(json) }
      return nodes
    end
    
    # Find or Create
    # @return Node
    # @example
    #   Cocupu::Node.find_or_create{'identity'=>"my_identity", 'pool'=>"pool_20", "node" => {'model_id' => 22, 'data' => {'file_name'=>'my file.xls'}} }
    def self.find_or_create(values)
      conn = Thread.current[:cocupu_connection] 
      identity = values["identity"]
      pool = values["pool"]
      response = conn.post("/#{identity}/#{pool}/nodes/find_or_create.json", body: {node: values["node"]})
      raise "Error trying to find_or_create node: #{response.inspect}" unless response.code >= 200 and response.code < 300
      if (response['persistent_id'])
        result = self.new(response)
      end
      result
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
    
    def associations
      values['associations']
    end
    
    def data=(data)
      values["data"] = data
    end
        
    def data
      values["data"]
    end

    def persistent_id
      values['persistent_id']
    end

    def save
      response = if persistent_id
        conn.put("#{url}/#{persistent_id}.json", body: {node: values})
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

    def attach_file(file_name, file)
      raise RuntimeError, "You can't attach a file to an object that hasn't been persisted" unless persistent_id
      Cocupu::File.new(self, file_name, file)

    end

  end

end
