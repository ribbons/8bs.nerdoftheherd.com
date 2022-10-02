# frozen_string_literal: true

# Copyright © 2022 Matt Robinson
#
# SPDX-License-Identifier: GPL-3.0-or-later

require_relative 'bbc_helpers'

module BBC
  describe BBCFile do
    it 'sets attribute values from constructor' do
      file = described_class.new(0, '$', 'TEST', 0x1234, 0x5678, 'CONTENT')

      expect(file).to have_attributes(
        side: 0,
        dir: '$',
        name: 'TEST',
        loadaddr: 0x1234,
        execaddr: 0x5678,
        content: 'CONTENT'
      )
    end

    it 'overrides constructor values with those from tweaks' do
      file = described_class.new(0, '$', 'TEST', 0x1234, 0x5678, 'CONTENT',
                                 { loadaddr: 0x9ABC, execaddr: 0xDEF0 })

      expect(file).to have_attributes(
        loadaddr: 0x9ABC,
        execaddr: 0xDEF0
      )
    end

    it 'calculates length-related attributes from content' do
      file = described_class.new(0, '$', 'TEST', 0x0, 0x0, 'FILE CONTENT')

      expect(file).to have_attributes(
        length: 12,
        empty?: false
      )
    end

    it 'calculates length-related attributes from empty content' do
      file = described_class.new(0, '$', 'TEST', 0x0, 0x0, '')

      expect(file).to have_attributes(
        length: 0,
        empty?: true
      )
    end

    it 'returns requested data when performing a shift' do
      file = described_class.new(0, '$', 'TEST', 0x0, 0x0, 'FILE CONTENT')
      expect(file.shift(5)).to eq('FILE ')
    end

    it 'updates length-related attributes after shift' do
      file = described_class.new(0, '$', 'TEST', 0x0, 0x0, 'FILE CONTENT')
      file.shift(5)

      expect(file).to have_attributes(
        length: 7,
        empty?: false
      )
    end

    it 'updates length-related attributes after shift of all data' do
      file = described_class.new(0, '$', 'TEST', 0x0, 0x0, 'FILE CONTENT')
      file.shift(12)

      expect(file).to have_attributes(
        length: 0,
        empty?: true
      )
    end
  end
end
