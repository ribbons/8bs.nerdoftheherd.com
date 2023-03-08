# encoding: ASCII-8BIT
# frozen_string_literal: true

# Copyright © 2021-2023 Matt Robinson
#
# SPDX-License-Identifier: GPL-3.0-or-later

require_relative '../../_plugins/BBC/bbc_native'
require_relative 'bbc_helpers'

RSpec.configure do |c|
  c.include BBCHelpers
end

module BBC
  describe ArcFile do
    it 'returns nil from a zero-length file' do
      file = file_from_string('')
      expect(described_class.parse(file)).to be_nil
    end

    it 'returns nil from parsing file not starting with a valid value' do
      file = file_from_string('X')
      expect(described_class.parse(file)).to be_nil
    end

    it 'returns nil from parsing non-archive starting with 0x1a00' do
      file = file_from_string("\x1a\x00ABCD")
      expect(described_class.parse(file)).to be_nil
    end

    it 'returns nil from parsing truncated header' do
      file = file_from_string("\x1a\x08AFILENAME123\x0")
      expect(described_class.parse(file)).to be_nil
    end

    it 'returns nil from parsing archive with truncated content' do
      file = get_file('arc_file_trunc_content')
      expect(described_class.parse(file)).to be_nil
    end

    it 'correctly loads files from archive' do
      archive = described_class.parse(get_file('arc_file_simple'))

      expect(archive.files).to contain_exactly(
        have_attributes(
          side: 0,
          dir: '$',
          name: 'TEXT',
          loadaddr: 0xFFFFFFFF,
          execaddr: 0xFFFFFFFF,
          content: 'TEXT  TEXT  TEXT'
        ),
        have_attributes(
          side: 0,
          dir: '$',
          name: 'TEXT1',
          loadaddr: 0xFFFFFFFF,
          execaddr: 0xFFFFFFFF,
          content: 'TEXT1 TEXT1 TEXT1'
        )
      )
    end

    it 'passes correct tweaks to archive files' do
      archive = described_class.parse(
        get_file('arc_file_simple',
                 tweaks: {
                   files: {
                     'TEXT' => { loadaddr: 0xFFFF1234 },
                     'TEXT1' => { execaddr: 0x00005678 },
                   },
                 })
      )

      expect(archive.files).to contain_exactly(
        have_attributes(
          name: 'TEXT',
          loadaddr: 0xFFFF1234
        ),
        have_attributes(
          name: 'TEXT1',
          execaddr: 0x00005678
        )
      )
    end
  end
end
