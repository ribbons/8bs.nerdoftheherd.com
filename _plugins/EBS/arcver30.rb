# frozen_string_literal: true

# This file is part of the 8BS Online Conversion.
# Copyright © 2017 by the authors - see the AUTHORS file for details.
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

module EBS
  require_relative 'archive'

  class ArcVer30 < Archive
    def initialize(disc, data)
      @disc = disc

      3.times do
        if read_value(data) != 0
          raise 'Archive doesn\'t start with three zero ints'
        end
      end

      version = read_value(data)
      raise 'Unknown archive version ' + version if version != '3.0'

      file_count = read_value(data)

      unless read_value(data).is_a?(Integer)
        raise 'Invalid archive, expected total'
      end

      unless read_value(data).is_a?(String)
        raise 'Invalid archive, expected creator'
      end

      unless read_value(data).is_a?(String)
        raise 'Invalid archive, expected date'
      end

      # Skip over all lines of the notes
      read_value(data).times do
        unless read_value(data).is_a?(String)
          raise 'Invalid archive, expected note line'
        end
      end

      @files = {}

      file_data = Array.new(file_count) do
        file = {
          name: read_value(data),
          load_addr: read_value(data),
          exec_addr: read_value(data),
          length: read_value(data)
        }

        raise 'File entry should end with zero int' if read_value(data) != 0

        file
      end

      file_data.each do |file|
        # Each file has a number written before it for some reason
        unless read_value(data).is_a?(Integer)
          raise 'Invalid archive, expected int'
        end

        splitname = file[:name].split('.', 2)
        dir = splitname.count == 1 ? '$' : splitname.shift
        justname = splitname.shift
        canon = @disc.canonicalise_path(file[:name])

        @files[canon] = ArchiveFile.new(dir, justname, file[:length],
                                        file[:load_addr], file[:exec_addr],
                                        data.shift(file[:length]).pack('c*'))
      end
    end
  end
end
