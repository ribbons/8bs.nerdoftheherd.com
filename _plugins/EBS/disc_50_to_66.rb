# This file is part of the 8BS Online Conversion.
# Copyright © 2007-2015 by the authors - see the AUTHORS file for details.
#
# This program is free software: you can redistribute it and/or modify it under the terms of the GNU General
# Public License as published by the Free Software Foundation, either version 3 of the License, or (at your
# option) any later version.
#
# This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the
# implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public
# License for more details.
#
# You should have received a copy of the GNU General Public License along with this program.  If not, see
# <http://www.gnu.org/licenses/>.

module EBS
  class Disc50To66 < Disc
    def initialize(issue, imagepath)
      super(issue, imagepath)

      disc = BBC::DfsDisc.new(imagepath)
      file = disc.file('$.!BOOT')

      lines = read_data_lines(file.content).values
      vals = lines.shift

      @date = Date.strptime(vals[1].tr('.', '/'), '%d/%m/%y')
      @menuid = 1

      convert_menu_data(lines, file.disc)
    end

    def convert_menu_data(lines, disc)
      until (vals = lines.shift).nil?
        menu = Menu.new
        menu.title = vals[0]
        entries = Integer(vals[1])

        menu.id = @menuid
        @menuid += 1

        entries.times do
          vals = lines.shift

          entry = MenuEntry.new(disc, @linkpaths)
          entry.title = vals[0]
          entry.paths = [vals[1] + '.' + vals[2]] if vals[1] != ''

          action = vals[3]

          case action.to_i
          when 1..10
            # Another menu
            entry.type = :menu
            entry.id = action.to_i
          when -1
            # 80 Column Text
            entry.type = :mode0
          when -2
            # 40 Column Text
            entry.type = :mode7
          when -4, -6
            # Basic Program / Lists BASIC
            entry.type = :basic
          when -7
            # Uses LDPIC
            entry.type = :ldpic
          when -8
            # *RUN
            entry.type = :run
          else
            case action.upcase
            when '*RUN'
              entry.type = :run
            else
              throw 'Unknown action type: ' + action
            end
          end

          menu.entries << entry
        end

        @menus << menu
      end
    end
  end
end
