module Cocupu
  class Model
    attr_accessor :values, :conn
    def initialize(values)
      self.conn = Thread.current[:cocupu_connection] 
      self.values = values
    end
    
    def self.find(identity, pool, args)      
      unless args == :all
        raise Exception "Cocupu::Model.find only supports one use case - find all. Try Cocupu::Model.find(identity, pool, :all)."
      end
      conn = Thread.current[:cocupu_connection]
      url = "/#{identity}/#{pool}/models.json"
      models_json = JSON.parse(conn.get(url).body)
      models = models_json.map {|json| Cocupu::Model.new(json) }
      return models
    end
    
    def self.load(id)
      conn = Thread.current[:cocupu_connection]
      url = "/models/#{id}.json"
      json = JSON.parse(conn.get(url).body)
      return Cocupu::Model.new(json)
    end

    def convert_data_keys(data_to_convert)
      converted_data = []
      data_as_array = data_to_convert.kind_of?(Array) ? data_to_convert : [data_to_convert]
      data_as_array.each do |data_hash|
        new_data = data_hash.dup
        fields.each do |field|
          field_code = field["code"]
          id_string = field["id"]
          new_data[id_string] = new_data.delete(field_code) unless new_data[field_code].nil?
        end
        converted_data << new_data
      end
      converted_data = converted_data.first unless data_to_convert.kind_of? Array
      return converted_data
    end

    def name
      values['name']
    end
    
    def name=(name)
      values['name'] = name
    end

    def label=(label)
      values['label'] = label
    end
    
    def label
      values['label'] 
    end
    
    def allow_file_bindings=(boolean)
      values['allow_file_bindings'] = boolean
    end
    
    def allow_file_bindings
      values['allow_file_bindings'] 
    end
    
    def allows_file_bindings?
      allow_file_bindings
    end

    def identity
      values['identity']
    end

    def pool
      values['pool']
    end

    def url
      values['url'] || "/#{identity}/#{pool}/models"
    end

    def url=(url)
      values['url'] = url
    end

    def id=(id)
      values['id'] = id
    end

    def fields=(fields)
      values['fields'] = fields
    end
    
    def fields
      values['fields']
    end

    def associations=(fields)
      values['associations'] = fields
    end
    
    def associations
      values['associations']
    end

    def id
      values['id']
    end

    def save
      #req_url = "http://#{host}:#{port}#{url}.json?auth_token=#{token}"
      response = if id
        conn.put("#{url}.json", body: {model: values})
      else
        conn.post("#{url}.json", body: {model: values})
      end
      raise "Error saving models: #{response.inspect}" unless response.code >= 200 and response.code < 300
      if (response['id'])
        self.id = response['id']
        self.url = response['url']
      end
      values
    end

  end
end
