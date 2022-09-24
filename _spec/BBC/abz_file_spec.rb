# encoding: ASCII-8BIT
# frozen_string_literal: true

# Copyright © 2022 Matt Robinson
#
# SPDX-License-Identifier: GPL-3.0-or-later

require_relative '../../_plugins/BBC/bbc_native'
require_relative '../../_plugins/BBC/mode7_file'
require_relative 'bbc_helpers'

RSpec.configure do |c|
  c.include BBCHelpers
end

module BBC
  describe AbzFile do
    it 'returns nil from parsing empty file' do
      file = file_from_string('')
      expect(described_class.parse(file)).to be_nil
    end

    it 'returns nil from parsing file not a multiple of 1024 bytes' do
      file = get_file('abz_file_trunc')
      expect(described_class.parse(file)).to be_nil
    end

    it 'returns nil from parsing file with less than 23 printable lines' do
      file = get_file('abz_file_22lines')
      expect(described_class.parse(file)).to be_nil
    end

    it 'returns correct screen data from a 23 line ABZ file' do
      file = get_file('abz_file_23lines')

      expect(described_class.parse(file).screendata).to eq(
        (' ' * 40) + 'A VERY SIMPLE'.ljust(40) + "SCREEN 1 \xFF".ljust(960) +
        'A VERY SIMPLE'.ljust(40) + "SCREEN 2 \xFF".ljust(920)
      )
    end

    it 'returns correct screen data from a 24 line ABZ file' do
      file = get_file('abz_file_24lines')

      expect(described_class.parse(file).screendata).to eq(
        (' ' * 40) + 'A VERY SIMPLE SCREEN 1'.ljust(920) + 'LINE 24'.ljust(80) +
        'A VERY SIMPLE SCREEN 2'.ljust(920) + 'LINE 24'.ljust(40)
      )
    end

    it 'returns correct screen data from a 25 line ABZ file' do
      file = get_file('abz_file_25lines')

      expect(described_class.parse(file).screendata).to eq(
        'A VERY SIMPLE SCREEN 1'.ljust(960) + 'LINE 25'.ljust(40) +
        'A VERY SIMPLE SCREEN 2'.ljust(960) + 'LINE 25'.ljust(40)
      )
    end
  end
end
