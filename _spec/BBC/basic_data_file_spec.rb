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

require_relative '../../_plugins/BBC/basic_data_file'
require_relative 'bbc_helpers'

RSpec.configure do |c|
  c.include BBCHelpers
end

module BBC
  describe BasicDataFile do
    it 'returns nil from parsing file not starting with a valid value' do
      file = file_from_string('X')
      expect(described_class.parse(file)).to be_nil
    end

    it 'returns integer and string values as the correct types' do
      basicdata = described_class.parse(get_file('basic_data_file_types'))
      expect(basicdata.values).to eql(['A STRING', 1_234_567_890])
    end
  end
end
