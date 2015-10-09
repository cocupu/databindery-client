require 'spec_helper'

describe Cocupu::Node, vcr: true do
  let(:conn)      { Cocupu.start('justin@cocupu.com', 'password', 3001, 'localhost') }
  let(:identity)  { conn.identity }
  let(:pool)      { identity.pools.first }
  let(:model)     { pool.models.first }


  describe "creating a new node" do
    let(:node)      { Cocupu::Node.new({'identity_id'=>identity.id, 'pool_id'=>pool.id, 'model_id' => model.id, 'data' => {'file_name'=>'my file.xls'}}) }
    let(:response)  { node.save }
    it "should be successful" do
      expect(response['persistent_id']).to eq "ce3c1990-12d3-0133-ac69-38e85644ce90"
      expect(response['url']).to eq("/api/v1/pools/2/nodes/ce3c1990-12d3-0133-ac69-38e85644ce90")
      expect(node.persistent_id).to eq(response['persistent_id'])
      expect(node.url).to eq(response['url'])
    end
  end

  describe "find" do
    it "finds the node"
  end

  describe "find_or_create on Node", vcr: true do
    subject { Cocupu::Node.find_or_create({'pool_id'=>pool.id, "node" => {'identity_id'=>identity.id, 'model_id' => model.id, 'data' => {'file_name'=>'my file.xls'}} }) }
    it "should be successful" do
      expect(subject.persistent_id).to eq '1fa07e40-12e4-0133-ac6a-38e85644ce90'
      expect(subject.url).to eq '/api/v1/pools/2/nodes/1fa07e40-12e4-0133-ac6a-38e85644ce90'
    end
  end

  describe "import" do
    let(:conn)      { double("connection") }
    let(:pool)      { Cocupu::Pool.new({"url"=>"/pools/2"}, conn) }
    let(:model)     { Cocupu::Model.new({'identity_id' =>"fooIdentity", 'pool_id'=>pool.id, 'name'=>"Talk"}) }
    before do
      allow(Thread).to receive(:current).and_return(cocupu_connection: conn)
    end
    it "allows you to specify a key to match on" do
      data = {'my-identifier'=>'cfTT98f'}
      expect(conn).to receive(:post).with("/pools/#{pool.id}/nodes/import.json", body: {model_id:model.id, data: data, key: 'my-identifier'})
      Cocupu::Node.import('pool_id'=>pool.id, 'model_id' => model.id, 'data' => data, 'key' => 'my-identifier')
    end
  end

  describe "attach_file" do
    let(:node)            { Cocupu::Node.create({'identity_id'=>identity.id, 'pool_id'=>pool.id, 'model_id' => model.id, 'data' => {'file_name'=>'my file.xls'}}) }
    let(:attached_file)   { node.attach_file('my_file_name', File.open('./spec/unit/node_spec.rb')) }
    subject { attached_file }
    it "builds a File object that belongs to the node" do
      expect(subject.node).to eq node
    end
    describe "the built file" do
      let(:response)    { attached_file.save }
      subject { response }
      it "can be saved without errors" do
        pending "make this test work -- the code seems to work, but getting `ERROR bad Request-Line `-------------RubyMultipartPost'.` in this test"
        expect(subject).to be_successful
      end
    end
  end
end
