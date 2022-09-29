# encoding: ASCII-8BIT
# frozen_string_literal: true

# Copyright © 2021-2022 Matt Robinson
#
# SPDX-License-Identifier: GPL-3.0-or-later

require_relative '../../_plugins/BBC/basic_data_file'
require_relative 'bbc_helpers'

RSpec.configure do |c|
  c.include BBCHelpers
end

module BBC
  describe BasicDataFile do
    it 'returns nil from parsing file not starting with a valid value' do
      file = file_from_string('X')
      expect(described_class.parse(file)).to be_nil
    end

    it 'returns nil from parsing string missing a length' do
      file = file_from_string("\x00")
      expect(described_class.parse(file)).to be_nil
    end

    it 'returns nil from parsing a truncated string' do
      file = file_from_string("\x00\x05ABC")
      expect(described_class.parse(file)).to be_nil
    end

    it 'returns nil from parsing a truncated real' do
      file = file_from_string("\xFF\x00\x60\x20\x71")
      expect(described_class.parse(file)).to be_nil
    end

    it 'returns integer, string and real values as the correct types' do
      basicdata = described_class.parse(get_file('basic_data_file_types'))
      expect(basicdata.values).to eql(['A STRING', 1_234_567_890, 123_456.75])
    end

    it 'returns correct real values for positive, negative and zero' do
      basicdata = described_class.parse(
        get_file('basic_data_file_real_sign_zero')
      )

      expect(basicdata.values).to eql([0.75, 0.0, -0.75])
    end
  end
end
