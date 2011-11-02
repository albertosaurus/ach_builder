require 'spec_helper'

describe "ACH::File parsing capabilities" do
  before(:all) do
    filename = File.dirname(__FILE__) + '/sample/file.ach.txt'
    @file = ACH::File.read(filename)
  end

  it "should have header" do
    @file.header.should_not be_nil
  end

  it "should have 2 batches" do
    @file.batches.length.should == 2
  end

  it "should have entry and addenda records under batches" do
    @file.batches.each do |batch|
      batch.entries.length.should == 1
      batch.addendas.length.should == 1
    end
  end

  it "should have control record" do
    @file.control.should_not be_nil
  end
end