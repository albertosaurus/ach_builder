require 'spec_helper'

describe ACH::Reader do

  context "from_string" do
    before :each do
      @content = ''
    end

    it "should return instance of the ACH::File" do
      ACH::Reader.from_string(@content).should be_instance_of ACH::File
    end
  end

  context "from_file" do
    before :each do
      @filename = well_fargo_empty_filename
    end

    it "should return instance of the ACH::File" do
      ACH::Reader.from_file(@filename).should be_instance_of ACH::File
    end
  end
end