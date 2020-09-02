# frozen_string_literal: true

# This file is part of the 8BS Online Conversion.
# Copyright © 2017-2020 by the authors - see the AUTHORS file for details.
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

  class Arc2 < Archive
    def initialize(data, arcfix)
      @files = {}

      loop do
        raise 'Entry doesn\'t start with valid marker' if data.shift != 0x1A

        type = data.shift

        # 0x00 = End of archive
        break if type.zero?

        # 0x08 = Dynamic LZW compression
        raise 'Unexpected compression version' unless type == 0x08

        namebytes = data.shift(13)
        filename = String.new

        namebytes.each do |b|
          break if b.zero?

          filename << b.chr
        end

        compr_length = read_size(data)

        # Skip the file date, time & CRC
        data.shift(6)

        length = read_size(data)
        decomp_data = decompress(data.shift(compr_length).pack('c*'), length)

        canon = BBC::DfsDisc.canonicalise_path(filename)
        loadaddr = 0xFFFFFFFF
        execaddr = 0xFFFFFFFF

        if !arcfix.nil? && arcfix.key?(filename)
          entry = arcfix[filename]
          loadaddr = entry[:load] if entry.key?(:load)
          execaddr = entry[:exec] if entry.key?(:exec)
        end

        @files[canon] = BBC::BBCFile.new(0, '$', filename, loadaddr, execaddr,
                                         decomp_data)
      end
    end

    def read_size(data)
      data.shift | data.shift << 8 | data.shift << 16 | data.shift << 24
    end
  end

  require_relative 'arc2_c'
end
