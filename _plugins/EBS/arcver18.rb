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

  class ArcVer18 < Archive
    def initialize(disc, data)
      @disc = disc
      @files = {}

      until data.empty?
        filename = read_value(data)
        length = read_value(data)
        load_addr = read_value(data)
        exec_addr = read_value(data)

        splitname = filename.split('.', 2)
        dir = splitname.count == 1 ? '$' : splitname.shift
        justname = splitname.shift
        canon = @disc.canonicalise_path(filename)

        @files[canon] = ArchiveFile.new(dir, justname, length,
                                        load_addr, exec_addr,
                                        data.shift(length).pack('c*'))
      end
    end
  end
end
