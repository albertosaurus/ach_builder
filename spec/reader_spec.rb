require 'spec_helper'

describe ACH::Reader do

  context "empty ACH file" do
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
        @result   = ACH::Reader.from_file(@filename)
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
      @result = ACH::Reader.from_string(@content)
    end

    subject { @result }

    it "should return instance of the ACH::File" do
      should be_instance_of ACH::File
    end

    it "should be converted to same content" do
      @result.to_s!.should == @content
    end
  end

end