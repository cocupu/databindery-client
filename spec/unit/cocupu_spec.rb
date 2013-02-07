require 'spec_helper'

describe Cocupu do

  before do
    FakeWeb.register_uri(:post, "http://localhost:3001/api/v1/tokens", :body => "{\"token\":\"112312\"}", :content_type => "text/json")
    @conn = Cocupu.start('justin@cocupu.com', 'password', 3001, 'localhost')
    @identity = 'my_id'
    @pool = 'my_pool'
  end

  describe "get pool list" do
    before do
      FakeWeb.register_uri(:get, "http://localhost:3001/identities?auth_token=112312", :body=>"[{\"url\":\"/identity/1234\",\"short_name\":\"fred\"},{\"url\":\"/identity/5677\",\"short_name\":\"my_id\"}]", :content_type => "text/json")
      FakeWeb.register_uri(:get, "http://localhost:3001/identity/5677.json?auth_token=112312", :body=>"[{\"short_name\":\"kiddy_pool\"}]", :content_type => "text/json")
    end
    it "should be successful" do
      pools = @conn.identity('my_id').pools
      pools.size.should == 1
      pools.first.short_name.should == 'kiddy_pool'
    end
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
  
  describe "find_or_create on Node" do
    before do
      FakeWeb.register_uri(:post, 'http://localhost:3001/my_id/my_pool/nodes/find_or_create.json?auth_token=112312', :body=>"{\"persistent_id\":\"909877\",\"url\":\"http://foo.bar/\"}", :content_type => "text/json")
    end
    it "should be successful" do
      node = Cocupu::Node.find_or_create({'identity'=>@identity, 'pool'=>@pool, "node" => {'model_id' => 22, 'data' => {'file_name'=>'my file.xls'}} })
      node.persistent_id.should == '909877'
      node.url.should == 'http://foo.bar/'
    end
  end

  describe "attach a file to the node" do
    before do
      FakeWeb.register_uri(:post, 'http://localhost:3001/my_id/my_pool/nodes/909877/files.json?auth_token=112312', :body=>"{\"persistent_id\":\"909877\",\"url\":\"http://foo.bar/\"}", :content_type => "text/json")
      @node = Cocupu::Node.new({'identity'=>@identity, 'pool'=>@pool, 'model_id' => 22, 'data' => {'file_name'=>'my file.xls'}})
      @node.persistent_id = '909877'
      @node.url = "/#{@identity}/#{@pool}/nodes/909877"
    end
    it "should be successful" do
      file = @node.attach_file('my_file_name', File.open('./spec/unit/cocupu_spec.rb'))
      file.save
    end

  end
end
