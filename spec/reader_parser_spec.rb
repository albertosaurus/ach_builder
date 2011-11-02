require 'spec_helper'

describe ACH::File::Reader::Parser do

  describe "with empty ACH" do
    before :each do
      @content = File.read(well_fargo_empty_filename)
      @parser  = ACH::File::Reader::Parser.new @content
    end

    context "run" do
      before :each do
        @result = @parser.run
      end

      subject { @result }
      it { should be_an Array }

      context "first element" do
        subject { @result.first }
        it { should be_an String }
      end

      context "last element" do
        subject { @result.last }
        it { should be_an String }
      end
    end
  end

  describe "with non-empty ACH" do
    before :each do
      @content = File.read(well_fargo_with_data)
      @parser  = ACH::File::Reader::Parser.new @content
    end

    context "run" do
      before :each do
        @result = @parser.run
      end

      subject { @result }
      it { should be_an Array }

      context "first element" do
        subject { @result.first }
        it { should be_an String }
      end

      context "last element" do
        subject { @result.last }
        it { should be_an String }
      end
    end
  end
end