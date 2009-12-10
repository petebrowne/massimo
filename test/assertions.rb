module Assertions

  # Assert that the two Arrays contain the same Strings or Symbols
  def assert_equal_arrays(expected_array, actual_array)
    assert_equal expected_array.map(&:to_s).sort, actual_array.map(&:to_s).sort
  end
  
end
