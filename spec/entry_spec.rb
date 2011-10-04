require 'spec_helper'

describe ACH::Entry do
  it "should have length of 94" do
    ACH::FileFactory.sample_file.batch(0).entry(0).to_s!.length.should == ACH::Constants::RECORD_SIZE
  end
end
