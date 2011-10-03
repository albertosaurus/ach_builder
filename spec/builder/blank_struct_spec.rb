require 'spec_helper'

describe ACH::Builder::BlankStruct do
  let(:struct) { ACH::Builder::BlankStruct.new }

  it "#method_missing adds new element" do
    struct.key_1 "value 1"  
    struct.key_2 "value 2"  

    hash = struct.to_hash
    hash[:key_1].should == "value 1"
    hash[:key_2].should == "value 2"
  end

  describe "#to_hash" do
    it "converts to hash recursively if block was passed to methods" do
      struct.name "White Queen"
      struct.position do
        x_pos 'd'
        y_pos 1
      end

      hash = struct.to_hash
      hash[:name].should == "White Queen"
      hash[:position][:x_pos].should == 'd'
      hash[:position][:y_pos].should ==  1
    end
  end
end