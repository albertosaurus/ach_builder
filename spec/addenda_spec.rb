require 'spec_helper'

describe ACH::Addenda do
  it "should have length of 94" do
    ACH::FileFactory.sample_file.batch(0).entry(0).to_s!.size.should == 94
  end
end
