# encoding: ASCII-8BIT
# frozen_string_literal: true

# Copyright © 2019-2020 Matt Robinson
#
# SPDX-License-Identifier: GPL-3.0-or-later

require_relative '../../_plugins/BBC/bbc_native'
require_relative 'bbc_helpers'

RSpec.configure do |c|
  c.include BBCHelpers
end

module BBC
  describe BasicFile do
    it 'returns nil from parsing file not starting with correct value' do
      file = get_file('basic_file_invalid')
      expect(described_class.parse(file)).to be_nil
    end

    it 'treats first byte of line number above 0x7f as EOF' do
      basic = described_class.parse(get_file('basic_file_eof'))
      expect(basic.lines.keys).not_to include(35_096)
    end

    it 'stores data line values from a BASIC file' do
      basic = described_class.parse(get_file('basic_file_data'))

      expect(basic.data).to include(
        20 => ['1', '2 ', '3', '4', ''],
        30 => ['HERE', '', 'IS  ', 'SOME', 'DATA '],
        2040 => ['', 'AND', '', 'SOME', 'MORE']
      )
    end

    it 'builds a hash of line display content' do
      basic = described_class.parse(get_file('basic_file_lines'))

      expect(basic.lines).to include(
        10 => 'REM BASIC TO TEST CONVERSION',
        20 => "PRINT \"STRING WITH\x81CONTROL CHAR\"",
        30 => 'RESTORE 32198',
        40 => '  DATA WITH,LEADING,SPACES',
        50 => " REMARK WITH\x81CONTROL CHAR"
      )
    end

    it 'returns listing MODE 7 equivalent in HTML format' do
      basic = described_class.parse(get_file('basic_file_html'))

      expect(basic.to_html).to eql(
        "   10PRINT \"HELLO WORLD\"                \n" \
        '20000PRINT "GOODBYE"                    '
      )
    end
  end
end
