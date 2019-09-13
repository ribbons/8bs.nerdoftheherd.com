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

require_relative '../../_plugins/BBC/bbc_file.rb'

module BBCHelpers
  def get_file(name)
    fullpath = File.expand_path('../test_data/' + name, __FILE__)
    content = File.open(fullpath, 'rb', &:read)

    BBC::BBCFile.new(0, '$', name, 0xFFFFFFFF, 0xFFFFFFFF, content)
  end
end
