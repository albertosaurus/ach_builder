require 'spec_helper'

describe ACH::Reader::Parser do

  describe "with empty ACH" do
    before :each do
      @content = File.read(well_fargo_empty_filename)
      @parser  = ACH::Reader::Parser.new @content
    end

    context "extracting header" do
      subject { @parser.detect_header_row }
      it  { should be_a String }
      it "should be a first line from ACH file" do
        should == @content.split("\n").first
      end
    end

    context "extracting control" do
      subject { @parser.detect_control_row }

      it { should be_a String }
      it "should be a last line from ACH file" do
        should == @content.split("\n").last
      end
    end

    context "extracting batches" do
      subject { @parser.detect_data_rows }
      it { should be_a Array }
      it { should be_empty }
    end

    context "run" do
      before :each do
        @result = @parser.run
      end

      subject { @result }
      it { should be_an Array }

      context "first element" do
        subject { @result.first }
        it "should be a header" do
          should be_an ACH::File::Header
        end
      end

      context "last element" do
        subject { @result.last }
        it "should be a control" do
          should be_an ACH::File::Control
        end
      end
    end
  end

  describe "with non-empty ACH" do
    before :each do
      @content = File.read(well_fargo_with_data)
      @parser  = ACH::Reader::Parser.new @content
    end

    context "extracting header" do
      subject { @parser.detect_header_row }
      it  { should be_a String }
      it "should be a first line from ACH file" do
        should == @content.split("\n").first
      end
    end

    context "extracting control" do
      subject { @parser.detect_control_row }

      it { should be_a String }
      it "should be a last line from ACH file" do
        should == @content.split("\n").last
      end
    end

    context "extracting batches" do
      before(:each) { @batches = @parser.detect_data_rows }
      subject { @batches }
      it { should be_a Array }
      it { should_not be_empty }
    end

    context "run" do
      before :each do
        @result = @parser.run
      end

      subject { @result }
      it { should be_an Array }

      context "first element" do
        subject { @result.first }
        it "should be a header" do
          should be_an ACH::File::Header
        end
      end

      context "last element" do
        subject { @result.last }
        it "should be a control" do
          should be_an ACH::File::Control
        end
      end
    end
  end
end