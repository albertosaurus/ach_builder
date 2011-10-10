require 'spec_helper'

describe ACH::Addenda do
  it "should have length of 94" do
    addenda = ACH::FileFactory.sample_file.batch(0).addendas.first
    addenda.to_s!.size.should == 94
  end
end
