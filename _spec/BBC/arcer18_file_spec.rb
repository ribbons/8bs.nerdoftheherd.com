# encoding: ASCII-8BIT
# frozen_string_literal: true

# This file is part of the 8BS Online Conversion.
# Copyright © 2021 by the authors - see the AUTHORS file for details.
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

require_relative '../../_plugins/BBC/arcer18_file'
require_relative 'bbc_helpers'

RSpec.configure do |c|
  c.include BBCHelpers
end

module BBC
  describe Arcer18File do
    it 'returns nil from a zero-length file' do
      file = file_from_string('')
      expect(described_class.parse(file)).to be_nil
    end

    it 'returns nil from parsing file not starting with a valid value' do
      file = file_from_string('X')
      expect(described_class.parse(file)).to be_nil
    end

    it 'returns nil from parsing file starting with the wrong type of value' do
      file = get_file('arcer18_file_wrongtype')
      expect(described_class.parse(file)).to be_nil
    end

    it 'correctly loads files from archive' do
      archive = described_class.parse(get_file('arcer18_file_simple'))

      expect(archive.files).to match_array(
        [
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
          ),
        ]
      )
    end
  end
end
