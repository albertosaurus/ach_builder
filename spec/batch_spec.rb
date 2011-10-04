require 'spec_helper'

describe ACH::Batch do
  before(:each) do
    @batch = ACH::Batch.new
    @file = ACH::FileFactory.sample_file
  end
  
  it "should create entry with attributes" do
    entry = @batch.entry :amount => 100
    entry.should be_instance_of(ACH::Entry)
    entry.amount.should == 100
  end
  
  it "should create entry with attributes" do
    entry = @batch.entry do
      amount 100
    end
    entry.amount.should == 100
  end
  
  it "should return false for has_credit? and has_debit? for empty entries" do
    @batch.has_credit?.should be_false
    @batch.has_debit?.should be_false
  end
  
  it "should return true for has_credit? if contains credit entry" do
    @batch.entry :amount => 100, :transaction_code => 21
    @batch.has_credit?.should be_true
  end
  
  it "should return true for has_debit? if contains debit entry" do
    @batch.entry :amount => 100
    @batch.has_debit?.should be_true
  end
  
  it "should generate 225 service_class_code for header if with debit entry only" do
    @batch.entry :amount => 100
    @batch.header.service_class_code.should == 225
  end
  
  it "should generate 220 service_class_code for header if with credit entry only" do
    @batch.entry :amount => 100, :transaction_code => 21
    @batch.header.service_class_code.should == 220
  end
  
  it "should generate 200 service_class_code for header if with debit and credit entries" do
    @batch.entry :amount => 100
    @batch.entry :amount => 100, :transaction_code => 21
    @batch.header.service_class_code.should == 200
  end
  
  it "should have header record with length of 94" do
    @file.batch(0).header.to_s!.length.should == ACH::Constants::RECORD_SIZE
  end
  
  it "should have control record with length of 94" do
    @file.batch(0).send(:before_header) # to fill service_class_code value
    @file.batch(0).control.to_s!.length.should == ACH::Constants::RECORD_SIZE
  end
end
