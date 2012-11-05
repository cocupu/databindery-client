require 'spec_helper'

describe Cocupu do

  before do
    FakeWeb.register_uri(:post, "http://localhost:3001/api/v1/tokens", :body => "{\"token\":\"112312\"}", :content_type => "text/json")
    Cocupu.start('justin@cocupu.com', 'password', 3001, 'localhost')
    @identity = 'my_id'
    @pool = 'my_pool'
  end

  describe "creating a new model" do
    before do
      FakeWeb.register_uri(:post, 'http://localhost:3001/my_id/my_pool/models.json?auth_token=112312', :body=>'{"id":"99"}', :content_type=>"text/json")
    end
    it "should be successful" do
      talk = Cocupu::Model.new({'identity' =>@identity, 'pool'=>@pool, 'name'=>"Talk"})
      talk.fields = [
       {"name"=>"File Name", "type"=>"text", "uri"=>"", "code"=>"file_name"},
       {"name"=>"Tibetan Title", "type"=>"text", "uri"=>"", "code"=>"tibetan_title"},
       {"name"=>"English Title", "type"=>"text", "uri"=>"", "code"=>"english_title"},
       {"name"=>"Author", "type"=>"text", "uri"=>"", "code"=>"author"},
       {"name"=>"Date", "type"=>"text", "uri"=>"", "code"=>"date"},
       {"name"=>"Time", "type"=>"text", "uri"=>"", "code"=>"time"},
       {"name"=>"Size", "type"=>"text", "uri"=>"", "code"=>"size"},
       {"name"=>"Location", "type"=>"text", "uri"=>"", "code"=>"location"},
       {"name"=>"Access", "type"=>"text", "uri"=>"", "code"=>"access"},
       {"name"=>"Originals", "type"=>"text", "uri"=>"", "code"=>"originals"},
       {"name"=>"Master", "type"=>"text", "uri"=>"", "code"=>"master"},
       {"name"=>"Notes", "type"=>"text", "uri"=>"", "code"=>"notes"},
       {"name"=>"Notes (cont)", "type"=>"text", "uri"=>"", "code"=>"notes2"}
       ]
       talk.label = 'file_name'
       talk.save
       talk.id.should == '99'
    end
  end

  describe "creating a new node" do
    before do
      FakeWeb.register_uri(:post, 'http://localhost:3001/my_id/my_pool/nodes.json?auth_token=112312', :body=>"{\"persistent_id\":\"909877\",\"url\":\"http://foo.bar/\"}", :content_type => "text/json")
    end
    it "should be successful" do
      node = Cocupu::Node.new({'identity'=>@identity, 'pool'=>@pool, 'model_id' => 22, 'data' => {'file_name'=>'my file.xls'}})
      node.save
      node.persistent_id.should == '909877'
      node.url.should == 'http://foo.bar/'
    end
  end

  describe "attach a file to the node" do
    it "should be successful" do
      node = Cocupu::Node.new({'identity'=>@identity, 'pool'=>@pool, 'model_id' => 22, 'data' => {'file_name'=>'my file.xls'}})
      node.save
      node.persistent_id.should == '909877'
      node.url.should == 'http://foo.bar/'
    end

  end
end
