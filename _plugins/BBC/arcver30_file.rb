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

  class Arcver30File < ArchiveFile
    def self.parse(file)
      return nil if file.empty?

      # Begins with three zero ints
      3.times do
        return nil if BasicDataFile.read_value(file) != 0
      end

      # File version
      return nil if BasicDataFile.read_value(file) != '3.0'

      file_count = BasicDataFile.read_value(file)

      # Total size of files, archive creator and date
      return nil unless BasicDataFile.read_value(file).is_a?(Integer)
      return nil unless BasicDataFile.read_value(file).is_a?(String)
      return nil unless BasicDataFile.read_value(file).is_a?(String)

      # Lines of notes
      BasicDataFile.read_value(file).times do
        return nil unless BasicDataFile.read_value(file).is_a?(String)
      end

      files = []

      file_data = Array.new(file_count) do
        fileinfo = {
          name: BasicDataFile.read_value(file),
          load_addr: BasicDataFile.read_value(file) & 0xFFFFFFFF,
          exec_addr: BasicDataFile.read_value(file) & 0xFFFFFFFF,
          length: BasicDataFile.read_value(file),
        }

        return nil if BasicDataFile.read_value(file) != 0

        fileinfo
      end

      file_data.each do |fileinfo|
        # Each file has a number written before it for some reason
        unless BasicDataFile.read_value(file).is_a?(Integer)
          raise 'Invalid archive, expected int'
        end

        splitname = fileinfo[:name].split('.', 2)
        dir = splitname.count == 1 ? '$' : splitname.shift
        justname = splitname.shift

        files << BBCFile.new(0, dir, justname, fileinfo[:load_addr],
                             fileinfo[:exec_addr],
                             file.shift(fileinfo[:length]))
      end

      Arcver30File.new(files)
    end
  end
end
