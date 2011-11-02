require 'spec_helper'

describe ACH::Record::Base do
  before(:all) do
    @test_record = Class.new(ACH::Record::Base) do
      fields :customer_name, :amount
      defaults :customer_name => 'JOHN SMITH'
    end
  end
  
  it "should have 2 ordered fields" do
    @test_record.fields.should == [:customer_name, :amount]
  end
  
  it "should create a record with default value" do
    @test_record.new.customer_name.should == 'JOHN SMITH'
  end
  
  it "should overwrite default value" do
    entry = @test_record.new(:customer_name => 'SMITH JOHN')
    entry.customer_name.should == 'SMITH JOHN'
  end
  
  it "should generate formatted string" do
    entry = @test_record.new :amount => 1599
    entry.to_s!.should == "JOHN SMITH".ljust(22) + "1599".rjust(10, '0')
  end
  
  it "should raise exception with unfilled value" do
    lambda{
      @test_record.new.to_s!
    }.should raise_error(ACH::Record::Base::EmptyField)
  end
end
