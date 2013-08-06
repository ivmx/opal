require File.expand_path('../../../spec_helper', __FILE__)
require File.expand_path('../fixtures/classes', __FILE__)
require File.expand_path('../shared/slice', __FILE__)

describe "Array#slice!" do
  it "removes and return the element at index" do
    a = [1, 2, 3, 4]
    a.slice!(10).should == nil
    a.should == [1, 2, 3, 4]
    a.slice!(-10).should == nil
    a.should == [1, 2, 3, 4]
    a.slice!(2).should == 3
    a.should == [1, 2, 4]
    a.slice!(-1).should == 4
    a.should == [1, 2]
    a.slice!(1).should == 2
    a.should == [1]
    a.slice!(-1).should == 1
    a.should == []
    a.slice!(-1).should == nil
    a.should == []
    a.slice!(0).should == nil
    a.should == []
  end

  it "removes and returns length elements beginning at start" do
    a = [1, 2, 3, 4, 5, 6]
    a.slice!(2, 3).should == [3, 4, 5]
    a.should == [1, 2, 6]
    a.slice!(1, 1).should == [2]
    a.should == [1, 6]
    a.slice!(1, 0).should == []
    a.should == [1, 6]
    a.slice!(2, 0).should == []
    a.should == [1, 6]
    a.slice!(0, 4).should == [1, 6]
    a.should == []
    a.slice!(0, 4).should == []
    a.should == []
  end

  it "properly handles recursive arrays" do
    empty = ArraySpecs.empty_recursive_array
    empty.slice(0).should == empty

    array = ArraySpecs.recursive_array
    array.slice(4).should == array
    array.slice(0..3).should == [1, 'two', 3.0, array]
  end

  pending "calls to_int on start and length arguments" do
    obj = mock('2')
    def obj.to_int() 2 end

    a = [1, 2, 3, 4, 5]
    a.slice!(obj).should == 3
    a.should == [1, 2, 4, 5]
    a.slice!(obj, obj).should == [4, 5]
    a.should == [1, 2]
    a.slice!(0, obj).should == [1, 2]
    a.should == []
  end

  pending "removes and return elements in range" do
    a = [1, 2, 3, 4, 5, 6, 7, 8]
    a.slice!(1..4).should == [2, 3, 4, 5]
    a.should == [1, 6, 7, 8]
    a.slice!(1...3).should == [6, 7]
    a.should == [1, 8]
    a.slice!(-1..-1).should == [8]
    a.should == [1]
    a.slice!(0...0).should == []
    a.should == [1]
    a.slice!(0..0).should == [1]
    a.should == []

    a = [1,2,3]
    a.slice!(0..3).should == [1,2,3]
    a.should == []
  end

  pending "calls to_int on range arguments" do
    from = mock('from')
    to = mock('to')

    # So we can construct a range out of them...
    def from.<=>(o) 0 end
    def to.<=>(o) 0 end

    def from.to_int() 1 end
    # def to.to_int() -2 end

    a = [1, 2, 3, 4, 5]

    a.slice!(from .. to).should == [2, 3, 4]
    a.should == [1, 5]

    lambda { a.slice!("a" .. "b")  }.should raise_error(TypeError)
    lambda { a.slice!(from .. "b") }.should raise_error(TypeError)
  end

  it "returns last element for consecutive calls at zero index" do
    a = [ 1, 2, 3 ]
    a.slice!(0).should == 1
    a.slice!(0).should == 2
    a.slice!(0).should == 3
    a.should == []
  end

  ruby_version_is "" ... "1.8.7" do
    # See http://groups.google.com/group/ruby-core-google/t/af70e3d0e9b82f39
    it "expands self when indices are out of bounds" do
      a = [1, 2]
      a.slice!(4).should == nil
      a.should == [1, 2]
      a.slice!(4, 0).should == nil
      a.should == [1, 2, nil, nil]
      a.slice!(6, 1).should == nil
      a.should == [1, 2, nil, nil, nil, nil]
      a.slice!(8...8).should == nil
      a.should == [1, 2, nil, nil, nil, nil, nil, nil]
      a.slice!(10..10).should == nil
      a.should == [1, 2, nil, nil, nil, nil, nil, nil, nil, nil]
    end
  end

  ruby_version_is "1.8.7" do
    pending "does not expand array with indices out of bounds" do
      a = [1, 2]
      a.slice!(4).should == nil
      a.should == [1, 2]
      a.slice!(4, 0).should == nil
      a.should == [1, 2]
      a.slice!(6, 1).should == nil
      a.should == [1, 2]
      a.slice!(8...8).should == nil
      a.should == [1, 2]
      a.slice!(10..10).should == nil
      a.should == [1, 2]
    end

    pending "does not expand array with negative indices out of bounds" do
      a = [1, 2]
      a.slice!(-3, 1).should == nil
      a.should == [1, 2]
      a.slice!(-3..2).should == nil
      a.should == [1, 2]
    end
  end

  ruby_version_is "" ... "1.9" do
    it "raises a TypeError on a frozen array" do
      lambda { ArraySpecs.frozen_array.slice!(0, 0) }.should raise_error(TypeError)
    end
  end

  ruby_version_is "1.9" do
    pending "raises a RuntimeError on a frozen array" do
      lambda { ArraySpecs.frozen_array.slice!(0, 0) }.should raise_error(RuntimeError)
    end
  end
end

describe "Array#slice" do
  pending do
    it_behaves_like(:array_slice, :slice)
  end
end
