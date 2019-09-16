# encoding: ASCII-8BIT
# frozen_string_literal: true

# This file is part of the 8BS Online Conversion.
# Copyright © 2019 by the authors - see the AUTHORS file for details.
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

require_relative '../../_plugins/BBC/bbc_native'
require_relative 'bbc_helpers.rb'

RSpec.configure do |c|
  c.include BBCHelpers
end

module BBC
  describe BasicFile do
    it 'returns nil from parsing file not starting with correct value' do
      file = get_file('basic_file_invalid')
      expect(BasicFile.parse(file)).to be_nil
    end

    it 'treats first byte of line number above 0x7f as EOF' do
      basic = BasicFile.parse(get_file('basic_file_eof'))
      expect(basic.lines.keys).not_to include(35_096)
    end

    it 'stores data line values from a BASIC file' do
      basic = BasicFile.parse(get_file('basic_file_data'))

      expect(basic.data).to include(
        20 => ['1', '2 ', '3', '4', ''],
        30 => ['HERE', '', 'IS  ', 'SOME', 'DATA '],
        2040 => ['', 'AND', '', 'SOME', 'MORE']
      )
    end

    it 'builds a hash of line display content' do
      basic = BasicFile.parse(get_file('basic_file_lines'))

      expect(basic.lines).to include(
        10 => 'REM BASIC TO TEST CONVERSION',
        20 => "PRINT \"STRING WITH\x81CONTROL CHAR\"",
        30 => 'RESTORE 32198',
        40 => '  DATA WITH,LEADING,SPACES',
        50 => " REMARK WITH\x81CONTROL CHAR"
      )
    end

    it 'returns listing MODE 7 equivalent in HTML format' do
      basic = BasicFile.parse(get_file('basic_file_html'))

      expect(basic.to_html).to eql(
        "   10PRINT \"HELLO WORLD\"                \n" \
        '20000PRINT "GOODBYE"                    '
      )
    end
  end
end
