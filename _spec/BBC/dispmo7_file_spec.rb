# frozen_string_literal: true

# Copyright © 2022 Matt Robinson
#
# SPDX-License-Identifier: GPL-3.0-or-later

require_relative '../../_plugins/BBC/bbc_native'
require_relative 'bbc_helpers'

RSpec.configure do |c|
  c.include BBCHelpers
end

module BBC
  describe Dispmo7File do
    it 'returns nil from parsing empty file' do
      file = file_from_string('', loadaddr: 0xE00, execaddr: 0xE03)
      expect(described_class.parse(file)).to be_nil
    end

    it 'returns nil from parsing file with a load address less than 0x0E' do
      file = get_file('dispmo7_file_d00', loadaddr: 0xD00, execaddr: 0xD02B)
      expect(described_class.parse(file)).to be_nil
    end

    it 'returns nil from parsing file with execute < load address + 4' do
      file = get_file(
        'dispmo7_file_oldloader', loadaddr: 0xE00, execaddr: 0xE03
      )

      expect(described_class.parse(file)).to be_nil
    end

    it 'returns nil from parsing file with data start < execute address' do
      file = get_file(
        'dispmo7_file_oldloader', loadaddr: 0x1000, execaddr: 0x102B
      )

      expect(described_class.parse(file)).to be_nil
    end

    it 'returns nil from parsing file with data end < data start address' do
      file = get_file(
        'dispmo7_file_invalidend', loadaddr: 0xE00, execaddr: 0xE2B
      )

      expect(described_class.parse(file)).to be_nil
    end

    it 'returns nil from parsing file shorter than data end address' do
      file = get_file(
        'dispmo7_file_trunc', loadaddr: 0xE00, execaddr: 0xE2B
      )

      expect(described_class.parse(file)).to be_nil
    end

    it 'returns nil from parsing file with a loader that is too long' do
      file = get_file(
        'dispmo7_file_oversize_loader', loadaddr: 0x1900, execaddr: 0x190B
      )

      expect(described_class.parse(file)).to be_nil
    end

    it 'returns correct screen data from a Dispmo7 file with an older loader' do
      file = get_file(
        'dispmo7_file_oldloader', loadaddr: 0xE00, execaddr: 0xE2B
      )

      expect(described_class.parse(file).screendata).to eq(
        'A VERY SIMPLE'.ljust(80) + 'MODE 7 SCREEN'.ljust(920)
      )
    end

    it 'returns correct screen data from a Dispmo7 file with a newer loader' do
      file = get_file(
        'dispmo7_file_newloader', loadaddr: 0x1900, execaddr: 0x1904
      )

      expect(described_class.parse(file).screendata).to eq(
        'ANOTHER VERY SIMPLE'.ljust(40) + 'MODE 7 SCREEN'.ljust(1480)
      )
    end
  end
end
