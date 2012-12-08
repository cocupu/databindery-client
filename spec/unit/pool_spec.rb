
require 'spec_helper'

describe Cocupu::Pool do
  before do
    FakeWeb.register_uri(:post, "http://localhost:3001/api/v1/tokens", :body => "{\"token\":\"112312\"}", :content_type => "text/json")
    @conn = Cocupu.start('justin@cocupu.com', 'password', 3001, 'localhost')
    @identity = 'my_id'
    @pool = Cocupu::Pool.new({"short_name"=>"my_pool", "url"=>"/#{@identity}/my_pool"}, @conn)
  end
  
  context "when listing models" do
    before do
      # @pool = Cocupu::Pool.new(v, @conn)
      model_json = '[{"id":36,"url":"/models/36","associations":[],"fields":[{"name":"Collection Name","type":"text","uri":"","code":"collection_name"},{"name":"Collection Location","type":"text","uri":"","code":"collection_location"},{"name":"Program Title - english","type":"text","uri":"","code":"program_title_english"},{"name":"Date from","type":"date","uri":"","code":"date_from"},{"name":"Date to","type":"date","uri":"","code":"date_to"},{"name":"Restricted?","type":"text","uri":"","code":"restricted"},{"name":"Copy or Original","type":"text","uri":"","code":"copy_or_original"},{"name":"Translation Languages","type":"text","uri":"","code":"translation_languages"},{"name":"Media","type":"text","uri":"","code":"media_type"},{"name":"# of Media","type":"text","uri":"","code":"number_of_media"},{"name":"Notes","type":"text_area","uri":"","code":"notes"},{"name":"Post-digi Notes","type":"text_area","uri":"","code":"post_digi_notes"}],"name":"Program","label":"program_title_english","pool":"marpa_test3","identity":"matt_zumwalt"},{"id":35,"url":"/models/35","associations":[],"fields":[{"name":"Location Name","type":"text","uri":"","code":"location_name"},{"name":"City State","type":"text","uri":"","code":"city_state"}],"name":"Location","label":"location_name","pool":"marpa_test3","identity":"matt_zumwalt"},{"id":34,"url":"/models/34","associations":[],"fields":[{"name":"Title - wylie","type":"text","uri":"","code":"title_wylie"},{"name":"Title - english","type":"text","uri":"","code":"title_english"},{"name":"Title - tibetan","type":"text","uri":"","code":"title_tibetan"}],"name":"Song","label":"title_english","pool":"marpa_test3","identity":"matt_zumwalt"},{"id":33,"url":"/models/33","associations":[],"fields":[{"name":"Title - wylie","type":"text","uri":"","code":"title_wylie"},{"name":"Title - english","type":"text","uri":"","code":"title_english"},{"name":"Title contractions","type":"text","uri":"","code":"title_contractions"},{"name":"Title - sanskrit","type":"text","uri":"","code":"title_sanskrit"},{"name":"Title - tibetan","type":"text","uri":"","code":"title_tibetan"}],"name":"Text","label":"title_english","pool":"marpa_test3","identity":"matt_zumwalt"},{"id":32,"url":"/models/32","associations":[],"fields":[{"name":"Name","type":"text","uri":"","code":"name"},{"name":"Code","type":"text","uri":"","code":"code"}],"name":"Contributor","label":"name","pool":"marpa_test3","identity":"matt_zumwalt"},{"id":1,"url":"/models/1","associations":[],"fields":[{"code":"file_name","type":"textfield"}],"name":"File Entity","label":"file_name"}]'
      FakeWeb.register_uri(:get, "http://localhost:3001/#{@identity}/#{@pool.short_name}/models.json?auth_token=112312", :body=>model_json, :content_type=>"text/json")
    end
    it "should initialize an array of Cocupu::Model objects" do
      @pool.models.count.should == 6
      @pool.models.each {|m| m.should be_instance_of Cocupu::Model }
    end
  end
  

end