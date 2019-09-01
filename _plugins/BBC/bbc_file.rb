# frozen_string_literal: true

# This file is part of the 8BS Online Conversion.
# Copyright © 2015-2019 by the authors - see the AUTHORS file for details.
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
  class BBCFile
    def initialize(disc, side, dir, name, startsector, length, loadaddr)
      @disc = disc
      @side = side
      @dir = dir
      @name = name
      @startsector = startsector
      @length = length
      @loadaddr = loadaddr
    end

    attr_reader :side, :dir, :name, :loadaddr, :disc

    def path
      ':' + @side.to_s + '.' + @dir.to_s + '.' + @name
    end

    def content
      data = String.new
      sector = @startsector
      remaining = @length.fdiv(DfsDisc::SECTOR_SIZE).ceil
      lastlen = (@length % DfsDisc::SECTOR_SIZE)
      lastlen = DfsDisc::SECTOR_SIZE if lastlen.zero?

      loop do
        buffer = @disc.read_sector(@side, sector)
        sector += 1
        remaining -= 1

        if remaining.zero?
          # Only include the sector data up to EOF
          data << buffer[0..lastlen - 1]
          return data
        end

        data << buffer
      end
    end
  end
end
