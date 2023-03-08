# encoding: ASCII-8BIT
# frozen_string_literal: true

# Copyright © 2021-2023 Matt Robinson
#
# SPDX-License-Identifier: GPL-3.0-or-later

require_relative '../../_plugins/BBC/arcver30_file'
require_relative 'bbc_helpers'

RSpec.configure do |c|
  c.include BBCHelpers
end

module BBC
  describe Arcver30File do
    it 'returns nil from a zero-length file' do
      file = file_from_string('')
      expect(described_class.parse(file)).to be_nil
    end

    it 'returns nil from parsing file not starting with a valid value' do
      file = file_from_string('X')
      expect(described_class.parse(file)).to be_nil
    end

    it 'correctly loads files from archive' do
      archive = described_class.parse(get_file('arcver30_file_simple'))

      expect(archive.files).to contain_exactly(
        have_attributes(
          side: 0,
          dir: '$',
          name: 'BASIC',
          loadaddr: 0xFFFF1900,
          execaddr: 0xFFFF8023,
          content: "\r\x00\n\r\xF1 \"HELLO\"\r\xFF"
        ),
        have_attributes(
          side: 0,
          dir: '$',
          name: 'TEXT',
          loadaddr: 0x00000000,
          execaddr: 0xFFFFFFFF,
          content: 'A Text File'
        )
      )
    end
  end
end
