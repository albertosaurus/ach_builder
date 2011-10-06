require 'spec_helper'
require 'ach/builder'

describe ACH::Builder do
  before(:all) do

    @builder_class = Class.new(ACH::Builder) do
      default_options do
        company_name "Company name"
        batch do
          effective_date "20111001"
          entry do
            customer_name  'JOHN SMITH'
          end
        end
      end
    end

  end


  describe ".default_options" do
    it "should respond to .default_options" do
      ACH::Builder.respond_to? :default_options
    end

    it "inits opts_hash with data specified in passed block" do
      hash = @builder_class.opts_hash
      hash[:company_name].should == "Company name"
      hash[:batch][:effective_date].should == "20111001"
      hash[:batch][:entry][:customer_name].should == "JOHN SMITH"
    end

    it 'accepts a hash of options' do
      builder = Class.new(ACH::Builder)
      builder.default_options(:band => 'Rainbow', :members => {:vocal => 'Dio', :guitar => 'Blackmore'}) do
        other_members(:vocal => 'Turner')
      end
      hash = builder.opts_hash
      hash[:band].should == 'Rainbow'
      hash[:members][:vocal].should == 'Dio'
      hash[:other_members][:vocal].should == 'Turner'
      hash[:members][:guitar].should == 'Blackmore'
    end

  end

  describe '.build' do
    it 'respond to .build' do
      @builder_class.should respond_to :build
    end

    it "should delegate to File#new, merging default values with passed fields" do
      expeted_arg = {:company_name => 'CN', :batch => {:effective_date => '20111001', :entry => {:customer_name => 'JOHN SMITH'}}}
      ACH::File.stub!(:new)
      ACH::File.should_receive(:new).with(expeted_arg)
      @builder_class.build(:company_name => 'CN')
    end

    it "works without default options" do
      ACH::File.stub!(:new)
      ACH::File.should_receive(:new).with({:aaa => 'bbb'})
      ACH::Builder.build(:aaa => 'bbb')
    end
  end
end
