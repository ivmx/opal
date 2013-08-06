require File.expand_path('../../../spec_helper', __FILE__)

ruby_version_is "1.8.7" do
  describe "Array#drop_while" do
    pending "removes elements from the start of the array while the block evaluates to true" do
      [1, 2, 3, 4].drop_while { |n| n < 4 }.should == [4]
    end

    pending "removes elements from the start of the array until the block returns nil" do
      [1, 2, 3, nil, 5].drop_while { |n| n }.should == [nil, 5]
    end

    pending "removes elements from the start of the array until the block returns false" do
      [1, 2, 3, false, 5].drop_while { |n| n }.should == [false, 5]
    end
  end
end
