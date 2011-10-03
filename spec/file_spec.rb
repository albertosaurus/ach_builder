require 'spec_helper'

describe ACH::File do
  before(:each) do
    @attributes = {
      :company_id => '11-11111',
      :company_name => 'MY COMPANY',
      :immediate_dest => '123123123',
      :immediate_dest_name => 'COMMERCE BANK',
      :immediate_origin => '123123123',
      :immediate_origin_name => 'MYCOMPANY' }
    @invalid_attributes = {:foo => 'bar'}
    @file = ACH::File.new(@attributes)
    @file_with_batch = ACH::File.new(@attributes) do
      batch :entry_class_code => 'WEB'
    end
    @sample_file = ACH.sample_file
  end
  
  it "should correctly assign attributes" do
    @file.company_id.should == '11-11111'
  end
  
  it "should be modified by calling attribute methods in block" do
    file = ACH::File.new(@attributes) do
      company_name "MINE COMPANY"
    end
    file.company_name.should == "MINE COMPANY"
  end
  
  it "should fetch and return header" do
    head = @file.header
    head.should be_instance_of(ACH::File::Header)
    head.immediate_dest.should == '123123123'
  end
  
  it "should be able to modify header info in block form" do
    file = ACH::File.new(@attributes) do
      header(:immediate_dest => '321321321') do
        immediate_dest_name 'BANK COMMERCE'
      end
    end
    head = file.header
    head.immediate_dest.should == '321321321'
    head.immediate_dest_name.should == 'BANK COMMERCE'
  end

  it 'should be able to specify subcomponents with nested hash' do
    header = {:header => {:immediate_dest => '321321321', :immediate_dest_name => 'BANK COMMERCE'}}
    file = ACH::File.new(@attributes.merge(header))
    head = file.header
    head.immediate_dest.should == '321321321'
    head.immediate_dest_name.should == 'BANK COMMERCE'
  end
  
  it "should raise exception on unknown attribute assignement" do
    lambda {
      ACH::File.new(@invalid_attributes)
    }.should raise_error(ACH::Component::UnknownAttribute)
  end
  
  it "should be able to create a batch" do
    @file_with_batch.batches.should_not be_empty
  end
  
  it "should return a batch when index is passed" do
    @file_with_batch.batch(0).should be_instance_of(ACH::Batch)
  end
  
  it "should assign a batch_number to a batch" do
    batch = @file_with_batch.batch(0)
    batch.batch_number.should == 1
    batch = @file_with_batch.batch(:entry_class_code => 'WEB')
    batch.batch_number.should == 2
  end
  
  it "should assign attributes to a batch" do
    batch = @file_with_batch.batch(0)
    batch.attributes.should include(@file_with_batch.attributes)
  end
  
  it "should have correct record count" do
    @sample_file.record_count.should == 8
  end
  
  it "should have header record with length of 94" do
    @sample_file.header.to_s!.length.should == ACH::Constants::RECORD_SIZE
  end
  
  it "should have control record with length of 94" do
    @sample_file.control.to_s!.length.should == ACH::Constants::RECORD_SIZE
  end
  
  it "should have length devisible by 94 (record size)" do
    (@sample_file.to_s!.gsub("\r\n", '').length % ACH::Constants::RECORD_SIZE).should be_zero
  end
end

