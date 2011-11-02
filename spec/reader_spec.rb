require 'spec_helper'

describe ACH::File::Reader do

  context "empty ACH file" do
    context "reading from string" do
      before :each do
        @content = File.read(well_fargo_empty_filename)
      end

      subject { ACH::File::Reader.from_string(@content) }

      it "should return instance of the ACH::File" do
        should be_instance_of ACH::File
      end
    end

    context "reading from file" do
      before :each do
        @filename = well_fargo_empty_filename
        @result   = ACH::File::Reader.from_file(@filename)
      end

      subject { @result }

      it "should return instance of the ACH::File" do
        should be_instance_of ACH::File
      end
    end
  end

  context "ACH file with data" do
    before :each do
      @content = File.read(well_fargo_with_data)
      @result  = ACH::File::Reader.from_string(@content)
    end

    subject { @result }

    it "should return instance of the ACH::File" do
      should be_instance_of ACH::File
    end
  end

end