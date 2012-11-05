#!/usr/bin/env ruby

require 'httparty'
require 'cocupu/identity'
require 'cocupu/model'
require 'cocupu/node'

module Cocupu
  class Connection
    include HTTParty
    attr_accessor :token, :host, :port

    def initialize(email, password, port=80, host='localhost')
      self.host = host
      self.port = port
      response = self.class.post("http://#{host}:#{port}/api/v1/tokens", body: {email: email, password: password})
      raise "Error logging in: #{response}" unless response.code == 200
      self.token = response["token"]
    end

    def get(path)
        self.class.get(request_url(path))
    end

    def put(path, args={})
        self.class.put(request_url(path), args)
    end

    def post(path, args={})
        self.class.post(request_url(path), args)
    end

    def request_url(path)
      "http://#{host}:#{port}#{path}?auth_token=#{token}"
    end

    def identities
      return @identities if @identities
      response = self.class.get("http://#{host}:#{port}/identities?auth_token=#{token}")
      raise "Error getting identities: #{response}" unless response.code == 200
      @identities = response.map {|val| Identity.new(val, self)}
    end

    def identity(short_name)
      identities.find{|i| i.short_name == short_name}
    end

  end

  def self.start(email, password, port=80, host='localhost')
    Thread.current[:cocupu_connection] = Connection.new(email, password, port, host)
  end
end
