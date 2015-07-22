#!/usr/bin/env ruby

require 'httmultiparty'
require 'active_support/core_ext/object/to_param'
require 'active_support/core_ext/object/to_query'
require 'cocupu/identity'
require 'cocupu/pool'
require 'cocupu/model'
require 'cocupu/node'
require 'cocupu/file'
require 'cocupu/curator'
require 'json'

module Cocupu
  class Connection
    include HTTMultiParty
    attr_accessor :token, :host, :port, :token_auth_headers

    def initialize(port=80, host='localhost')
      self.host = host
      self.port = port
    end

    def authenticate(email, password)
      response = self.class.post("http://#{host}:#{port}/api/auth/sign_in.json", body: {email: email, password: password})
      raise "Error logging in: #{response}" unless response.code == 200
      update_token_auth_headers(response)
    end

    # Wraps regular httparty get, ensuring that tokenauth headers are updated after each request
    def get(path, params={}, args={})
        inject_token_auth_headers!(args)
        response = self.class.get(request_url(path, params), args)
        update_token_auth_headers(response)
        return response
    end

    # Wraps regular httparty put, ensuring that tokenauth headers are updated after each request
    def put(path, args={})
        inject_token_auth_headers!(args)
        response = self.class.put(request_url(path), args)
        update_token_auth_headers(response)
        return response
    end

    # Wraps regular httparty post, ensuring that tokenauth headers are updated after each request
    def post(path, args={})
        inject_token_auth_headers!(args)
        response = self.class.post(request_url(path), args)
        update_token_auth_headers(response)
        return response
    end

    # Wraps regular httparty get, ensuring that tokenauth headers are updated after each request
    def delete(path, params={}, args={})
      inject_token_auth_headers!(args)
      response = self.class.delete(request_url(path, params), args)
      update_token_auth_headers(response)
      return response
    end

    def request_url(path, params={})
      # params["auth_token"] = token
      relative_path = "/api/v1#{path.gsub('/api/v1','')}"
      "http://#{host}:#{port}#{relative_path}?#{url_params(params)}"
    end

    def url_params(params)
      params.respond_to?(:to_param) ? params.to_param : params
    end

    def identities
      return @identities if @identities
      response = get("/identities")
      raise "Error getting identities: #{response}" unless response.code == 200
      @identities = JSON.parse(response.body).map {|val| Identity.new(val)}
    end

    def identity(short_name=nil)
      if short_name
        return identities.find{|i| i.short_name == short_name}
      else
        return identities.first
      end
    end

    # Holds onto tokenauth headers for sumbission with future requests.
    # The access-token is replaced in the response headers from each request, so you must call this
    # after every request.
    def update_token_auth_headers(response)
      self.token_auth_headers ||= {}
      ['access-token','client','uid','expiry'].each do |header_name|
        self.token_auth_headers[header_name] = response.headers[header_name] unless response.headers[header_name].nil?
      end
      return token_auth_headers
    end

    def inject_token_auth_headers!(args)
      if args[:headers].nil?
        args[:headers] = {}
      end
      args[:headers].merge!(token_auth_headers)
      args
    end

  end

  def self.start(email, password, port=80, host='localhost')
    conn = Connection.new(port, host)
    conn.authenticate(email, password) unless email.nil? || password.nil?
    Thread.current[:cocupu_connection] = conn
  end
end
