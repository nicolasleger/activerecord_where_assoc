# frozen_string_literal: true

require "test_helper"

describe "wa_exists has_one" do
  let(:s0) { S0.create_default! }

  it "matches with Arel condition" do
    s0.create_assoc!(:o1, :S0_o1, adhoc_value: 1)
    assert_exists_with_matching(:o1, S1.arel_table[S1.adhoc_column_name].eq(1))
    assert_exists_without_matching(:o1, S1.arel_table[S1.adhoc_column_name].eq(2))
  end

  it "matches with Array-String condition" do
    s0.create_assoc!(:o1, :S0_o1, adhoc_value: 1)
    assert_exists_with_matching(:o1, ["#{S1.adhoc_column_name} = ?", 1])
    assert_exists_without_matching(:o1, ["#{S1.adhoc_column_name} = ?", 2])
  end

  it "matches with a block condition" do
    s0.create_assoc!(:o1, :S0_o1, adhoc_value: 1)
    assert_exists_with_matching(:o1) { |s| s.where(S1.adhoc_column_name => 1) }
    assert_exists_without_matching(:o1) { |s| s.where(S1.adhoc_column_name => 2) }
  end

  it "matches with Hash condition" do
    s0.create_assoc!(:o1, :S0_o1, adhoc_value: 1)
    assert_exists_with_matching(:o1, S1.adhoc_column_name => 1)
    assert_exists_without_matching(:o1, S1.adhoc_column_name => 2)
  end

  it "matches with String condition" do
    s0.create_assoc!(:o1, :S0_o1, adhoc_value: 1)
    assert_exists_with_matching(:o1, "#{S1.adhoc_column_name} = 1")
    assert_exists_without_matching(:o1, "#{S1.adhoc_column_name} = 2")
  end

  it "matches with Symbol condition" do
    s0.create_assoc!(:o1, :S0_o1, adhoc_value: 1)
    assert_exists_with_matching(:o1, :adhoc_is_one)
    assert_exists_without_matching(:o1, :adhoc_is_two)
  end
end
