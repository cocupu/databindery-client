require 'spec_helper'

describe Cocupu::Model do
  let(:conn)      { Cocupu.start('justin@cocupu.com', 'password', 3001, 'localhost') }
  let(:identity)  { conn.identity }
  let(:pool)      { identity.pools.first }

  describe "create", vcr: true do
    it "should be successful" do
      talk = Cocupu::Model.new({'identity_id' =>identity.id, 'pool_id'=>pool.id, 'name'=>"Talk"})
      talk.fields = [
          {"name"=>"File Name", "type"=>"TextField", "uri"=>"", "code"=>"file_name"},
          {"name"=>"Tibetan Title", "type"=>"TextField", "uri"=>"", "code"=>"tibetan_title"},
          {"name"=>"English Title", "type"=>"TextField", "uri"=>"", "code"=>"english_title"},
          {"name"=>"Author", "type"=>"TextField", "uri"=>"", "code"=>"author"},
          {"name"=>"Date", "type"=>"TextField", "uri"=>"", "code"=>"date"},
          {"name"=>"Time", "type"=>"TextField", "uri"=>"", "code"=>"time"},
          {"name"=>"Size", "type"=>"TextField", "uri"=>"", "code"=>"size"},
          {"name"=>"Location", "type"=>"TextField", "uri"=>"", "code"=>"location"},
          {"name"=>"Access", "type"=>"TextField", "uri"=>"", "code"=>"access"},
          {"name"=>"Originals", "type"=>"TextField", "uri"=>"", "code"=>"originals"},
          {"name"=>"Master", "type"=>"TextField", "uri"=>"", "code"=>"master"},
          {"name"=>"Notes", "type"=>"TextField", "uri"=>"", "code"=>"notes"},
          {"name"=>"Notes (cont)", "type"=>"TextField", "uri"=>"", "code"=>"notes2"}
      ]
      # talk.label_field_id = 'file_name'  # TODO add this to the test when resolved https://github.com/cocupu/databindery-api-server/issues/6
      talk.save
      expect(talk.id).to eq 99 # the stubbed http response assigns this id
    end
  end

end
