require 'spec_helper'

describe ACH::Reader::Parser do
  before :each do
    @content = File.read(well_fargo_empty_filename)
    @parser  = ACH::Reader::Parser.new @content
  end

  context "extracting header" do
    subject { @parser.detect_header }
    it "should be a string" do
      should be_a String
    end

    it "should be a first line from ACH file" do
      should == @content.split("\n").first
    end
  end

  context "extracting control" do
    subject { @parser.detect_control }

    it "should be a string" do
      should be_a String
    end

    it "should be a last line from ACH file" do
      should == @content.split("\n").last
    end
  end

  context "extracting batches" do
    subject { @parser.detect_batches }

    it "should be an array" do
      should be_a Array
    end

    it "should be empty" do
      should be_empty
    end
  end
end
