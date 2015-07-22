module Cocupu
  class Identity
    attr_accessor :values, :conn
    def initialize(values)
      self.conn = Thread.current[:cocupu_connection] 
      self.values = values
    end

    def create
      # TODO: Currently the only way to create an identity is to create a LoginCredential and then retrieve its automatically-built Identity
      # TODO: (cont'd) AND it requires clicking link in confirmation email...
      # Sample:
      #POST to "/api/auth"
      #Processing by DeviseTokenAuth::RegistrationsController#create as HTML
      #Parameters: {"identities_attributes"=>[{"short_name"=>"justin"}], "password"=>"password", "email"=>"justin@cocupu.com", "password_confirmation"=>"password", "confirm_success_url"=>"http://localhost:8000/demo.html#/create_account", "config_name"=>"default"}
      conn.post("#{url}.json", body: {identity: values})
    end

    def short_name
      values["short_name"]
    end

    def url
      values['url'] ||= id ? "/identities/#{id}" : "/identities"
    end

    def id
      values['id']
    end

    def pools
      return @pools if @pools
      response = conn.get("/pools")  # currently databindery GET /pools returns pools owned by the current identity
      raise "Error getting pools: #{response}" unless response.code == 200
      @pools = JSON.parse(response.body).map {|val| Pool.new(val, conn)}
    end

    def pool(short_name)
      pools.find{|i| i.short_name == short_name}
    end

  end

end
