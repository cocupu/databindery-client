#!/usr/bin/env ruby

require 'httmultiparty'
require 'cocupu/identity'
require 'cocupu/pool'
require 'cocupu/model'
require 'cocupu/node'
require 'cocupu/file'
require 'cocupu/curator'

module Cocupu
  class Connection
    include HTTMultiParty
    attr_accessor :token, :host, :port

    def initialize(email, password, port=80, host='localhost')
      self.host = host
      self.port = port
      response = self.class.post("http://#{host}:#{port}/api/v1/tokens", body: {email: email, password: password})
      raise "Error logging in: #{response}" unless response.code == 200
      self.token = response["token"]
    end

    def get(path, params={}, args={})
        self.class.get(request_url(path, params), args)
    end

    def put(path, args={})
        self.class.put(request_url(path), args)
    end

    def post(path, args={})
        self.class.post(request_url(path), args)
    end

    def request_url(path, params={})
      params["auth_token"] = token
      "http://#{host}:#{port}#{path}?#{url_params(params)}"
    end

    def url_params(params)
      params.map {|k,v| "#{k.to_s}=#{v}"}.join("&")
    end
    
    def identities
      return @identities if @identities
      response = self.class.get("http://#{host}:#{port}/identities?auth_token=#{token}")
      raise "Error getting identities: #{response}" unless response.code == 200
      @identities = response.map {|val| Identity.new(val)}
    end

    def identity(short_name)
      identities.find{|i| i.short_name == short_name}
    end

  end

  def self.start(email, password, port=80, host='localhost')
    Thread.current[:cocupu_connection] = Connection.new(email, password, port, host)
  end
end
