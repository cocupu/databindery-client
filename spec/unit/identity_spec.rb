require 'spec_helper'

describe Cocupu::Identity do
  let(:conn)      { Cocupu.start('justin@cocupu.com', 'password', 3001, 'localhost') }
  let(:identity)  { conn.identity }

  describe "create" do
    subject { Cocupu::Identity.create(short_name:"test_create") }
    it "creates a new Identity" do
      pending "TODO: Implement Identitity#create"
      # expect(subject.persisted?).to eq true
      expect(subject.id).to_not be_nil
    end
  end

  describe "pools", vcr:true do
    subject { identity.pools }
    it "returns the array of pools belonging to the identity" do
      expect(subject.size).to eq 4
      expect(subject.first.short_name).to eq 'kiddie_pool'
    end
  end

end
