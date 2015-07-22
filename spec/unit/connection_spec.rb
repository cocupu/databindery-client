require 'spec_helper'

describe Cocupu::Connection do
  let(:identity)  { 'my_id' }
  let(:pool)      { 'my_pool' }
  let(:conn)      { Cocupu.start('justin@cocupu.com', 'password', 3001, 'localhost') }

  describe "token handling", :vcr do
    let(:conn)  { Cocupu::Connection.new(3001, 'localhost') }
    describe "authenticate" do
      before do
        conn.authenticate('justin@cocupu.com', 'password')
      end
      it "should store tokenauth credentials from sign in" do
        expect(conn.token_auth_headers).to eq( {"access-token"=>"signin-token-#signin", "client"=>"client-id-#signin", "uid"=>"justin@cocupu.com", "expiry"=>"expiry-#signin"} )
      end
    end
    describe "get,put,post and delete", vcr:{:match_requests_on => [:headers, :path]} do
      # let(:conn)      { Cocupu::Connection.new('justin@cocupu.com', 'password', 3001, 'localhost') }
      let(:get_headers) { {'access-token'=>'signin-token-#get','client'=>'client-id-#get','uid'=>'padma@cocupu.com','expiry'=>'expiry-#get'}   }
      let(:put_headers) { {'access-token'=>'signin-token-#put','client'=>'client-id-#put','uid'=>'padma@cocupu.com','expiry'=>'expiry-#put'}   }
      let(:post_headers) { {'access-token'=>'signin-token-#post','client'=>'client-id-#post','uid'=>'padma@cocupu.com','expiry'=>'expiry-#post'}   }
      let(:delete_headers) { {'access-token'=>'signin-token-#delete','client'=>'client-id-#delete','uid'=>'padma@cocupu.com','expiry'=>'expiry-#delete'}   }
      before do
        # reset the token_auth_headers to something predictable
        conn.token_auth_headers = {'access-token'=>'signin-token-#auth','client'=>'client-id-#auth','uid'=>'padma@cocupu.com','expiry'=>'expiry-#auth'}
      end
      it "use tokenauth headers and updates them from response" do
        conn.send(:post, "/pools")
        expect(conn.token_auth_headers).to eq post_headers

        [:get,:put,:delete].each do |method|
          conn.send(method, "/pools/2")
          expect(conn.token_auth_headers).to eq self.send("#{method}_headers".to_sym)
        end
      end
    end
  end

  describe "request_url" do
    let(:conn)  { Cocupu::Connection.new }
    it "builds a valid url" do
      expect(conn.request_url("/pools/2/models.json")).to eq("http://localhost:80/api/v1/pools/2/models.json?")
    end
    it "does not inject /api/v1 if it is already there" do
      expect(conn.request_url("/api/v1/pools/2/models.json")).to eq("http://localhost:80/api/v1/pools/2/models.json?")
    end
  end

  describe "identities", vcr: true do
    subject   { conn.identities }
    it "returns the identities associated with the current login credential" do
      expect(subject.count).to eq 1
      expect(subject.first).to be_instance_of Cocupu::Identity
      expect(subject.first.short_name).to eq "the_short_name"
    end
  end

  describe "identity", :vcr do
    subject   { conn.identity }
    it "returns the first identity associated with the current login credential" do
      expect(subject).to be_instance_of Cocupu::Identity
      expect(subject.short_name).to eq "the_short_name"
    end
  end
end
