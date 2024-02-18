# frozen_string_literal: true

# Copyright © 2024 Matt Robinson
#
# SPDX-License-Identifier: GPL-3.0-or-later

require_relative '../../_plugins/BBC/bbc_native'
require_relative 'bbc_helpers'

RSpec.configure do |c|
  c.include BBCHelpers
end

module BBC
  describe Mode7ScreenFile do
    it 'returns nil from parsing file less than ten lines long' do
      file = file_from_string(' ' * 399, loadaddr: 0x7C00, execaddr: 0x7C00)
      expect(described_class.parse(file)).to be_nil
    end

    it 'returns nil from parsing file larger than 1024 bytes' do
      file = file_from_string(' ' * 1025, loadaddr: 0x7C00, execaddr: 0x7C00)
      expect(described_class.parse(file)).to be_nil
    end

    it 'returns nil from parsing file loaded below MODE 7 RAM' do
      file = file_from_string(' ' * 1000, loadaddr: 0x7817, execaddr: 0x7817)
      expect(described_class.parse(file)).to be_nil
    end

    it 'returns nil from parsing file loaded above unscrolled MODE 7 RAM' do
      file = file_from_string(' ' * 1000, loadaddr: 0x7FE8, execaddr: 0x7FE8)
      expect(described_class.parse(file)).to be_nil
    end

    it 'returns nil from parsing file with less than ten lines below end' do
      file = file_from_string(' ' * 1000, loadaddr: 0x7E58, execaddr: 0x7E58)
      expect(described_class.parse(file)).to be_nil
    end

    it 'returns all data from a 1000 byte screen dump loaded at &7C00' do
      file = file_from_string(
        'A VERY SIMPLE MODE 7 SCREEN'.ljust(1000),
        loadaddr: 0x7C00, execaddr: 0x7C00
      )

      expect(described_class.parse(file).screendata).to eq(
        'A VERY SIMPLE MODE 7 SCREEN'.ljust(1000)
      )
    end

    it 'returns visible section of a 1000 byte screen dump loaded at &7BFA' do
      file = file_from_string(
        'JUNK! FOLLOWED BY A SIMPLE MODE 7 SCREEN'.ljust(1000),
        loadaddr: 0x7BFA, execaddr: 0x7BFA
      )

      expect(described_class.parse(file).screendata).to eq(
        'FOLLOWED BY A SIMPLE MODE 7 SCREEN'.ljust(994)
      )
    end

    it 'returns first 1000 bytes from a 1024 byte dump loaded at &7C00' do
      file = file_from_string(
        'A SIMPLE MODE 7 SCREEN WITH EXTRA BYTES'.ljust(1024),
        loadaddr: 0x7C00, execaddr: 0x7C00
      )

      expect(described_class.parse(file).screendata).to eq(
        'A SIMPLE MODE 7 SCREEN WITH EXTRA BYTES'.ljust(1000)
      )
    end
  end
end
