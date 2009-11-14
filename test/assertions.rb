module Assertions

  # Assert that the two Arrays contain the same Strings or Symbols
  def assert_equal_arrays(arrayA, arrayB)
    assert_equal arrayA.map(&:to_s).sort, arrayB.map(&:to_s).sort
  end
  
end
