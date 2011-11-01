require 'spec_helper'

describe ACH::Reader do

  context "reading from string" do
    before :each do
      @content = File.read(well_fargo_empty_filename)
    end

    subject { ACH::Reader.from_string(@content) }

    it "should return instance of the ACH::File" do
      should be_instance_of ACH::File
    end
  end

  context "reading from file" do
    before :each do
      @filename = well_fargo_empty_filename
    end

    subject { ACH::Reader.from_file(@filename) }

    it "should return instance of the ACH::File" do
      should be_instance_of ACH::File
    end
  end

end