# frozen_string_literal: true

# This file is part of the 8BS Online Conversion.
# Copyright © 2017-2021 by the authors - see the AUTHORS file for details.
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

module BBC
  require_relative 'archive_file'

  class Arcer18File < ArchiveFile
    def self.parse(file)
      return nil if file.empty?

      files = []

      until file.empty?
        filename = BasicDataFile.read_value(file)
        return nil unless filename.is_a?(String)

        length = BasicDataFile.read_value(file)
        return nil unless length.is_a?(Integer)

        load_addr = BasicDataFile.read_value(file)
        return nil unless load_addr.is_a?(Integer)

        exec_addr = BasicDataFile.read_value(file)
        return nil unless exec_addr.is_a?(Integer)

        splitname = filename.split('.', 2)
        dir = splitname.count == 1 ? '$' : splitname.shift
        justname = splitname.shift

        files << BBCFile.new(0, dir, justname, load_addr & 0xFFFFFFFF,
                             exec_addr & 0xFFFFFFFF, file.shift(length))
      end

      Arcer18File.new(files)
    end
  end
end
