# encoding: ASCII-8BIT
# frozen_string_literal: true

# Copyright © 2022-2023 Matt Robinson
#
# SPDX-License-Identifier: GPL-3.0-or-later

require_relative '../../_plugins/BBC/telemag_file'
require_relative 'bbc_helpers'

RSpec.configure do |c|
  c.include BBCHelpers
end

module BBC
  describe TelemagFile do
    it 'returns nil from a zero-length file' do
      file = file_from_string('')
      expect(described_class.parse(file)).to be_nil
    end

    it 'returns nil from parsing file not starting with a valid value' do
      file = file_from_string('X')
      expect(described_class.parse(file)).to be_nil
    end

    it 'returns nil from parsing truncated file' do
      file = file_from_string("\xFF\x00\x00\x00\x00\x00TRUNCATED")
      expect(described_class.parse(file)).to be_nil
    end

    it 'correctly loads files from archive' do
      archive = described_class.parse(get_file('telemag_file'))

      expect(archive.files).to contain_exactly(
        have_attributes(
          side: 0,
          dir: '$',
          name: 'A',
          type: :mode7,
          content: 'THIS IS FILE 1'.ljust(1000)
        ),
        have_attributes(
          side: 0,
          dir: '$',
          name: 'B',
          type: :mode7,
          content: 'THIS IS FILE 2'.ljust(1040)
        )
      )
    end
  end
end
