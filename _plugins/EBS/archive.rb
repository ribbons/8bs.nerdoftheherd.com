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
  class Archive
    def self.from_file(file, fixdata)
      data = file.content.each_byte.to_a

      case data.first
      when 0x00
        ArcVer18.new(file.disc, data)
      when 0x40
        ArcVer30.new(file.disc, data)
      when 0x1A
        Arc2.new(file.disc, data, fixdata)
      else
        raise 'Unexpected first byte of archive'
      end
    end

    def files
      @files.values
    end

    def file(path)
      file = @files[@disc.canonicalise_path(path)]
      file&.content
    end

    private

    def read_value(data)
      type = data.shift

      case type
      when 0x00
        read_str(data)
      when 0x40
        read_int(data)
      else
        raise 'Malformed archive: Unexpected type value ' + type.to_s
      end
    end

    def read_int(data)
      (data.shift << 24) | (data.shift << 16) | (data.shift << 8) | data.shift
    end

    def read_str(data)
      length = data.shift

      value = ''

      (1..length).each do
        value = data.shift.chr + value
      end

      value
    end
  end
end
