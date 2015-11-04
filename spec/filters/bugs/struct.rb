opal_filter "Struct" do
  fails "Struct#hash returns the same fixnum for structs with the same content"
  fails "Struct#initialize can be overriden"
  fails "Struct#inspect returns a string representation of some kind"
  fails "Struct#instance_variables returns an array with one name if an instance variable is added"
  fails "Struct#instance_variables returns an empty array if only attributes are defined"
  fails "Struct#members does not override the instance accessor method"
  fails "Struct.new calls to_str on its first argument (constant name)"
  fails "Struct.new creates a constant in subclass' namespace"
  fails "Struct.new creates a new anonymous class with nil first argument"
  fails "Struct.new does not create a constant with symbol as first argument"
  fails "Struct.new fails with invalid constant name as first argument"
  fails "Struct.new fails with too many arguments"
  fails "Struct.new on subclasses creates a constant in subclass' namespace"
  fails "Struct.new on subclasses fails with too many arguments"
  fails "Struct.new raises a TypeError if object doesn't respond to to_sym"
  fails "Struct.new raises a TypeError if object is not a Symbol"
  fails "Struct.new with a block passes same struct class to the block"
end
