# frozen_string_literal: true

# This file is part of the 8BS Online Conversion.
# Copyright © 2007-2021 by the authors - see the AUTHORS file for details.
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

require_relative 'disc'

module EBS
  class Disc50To66 < Disc
    def initialize(site, issue, imagepath)
      super(site, issue, imagepath)

      lines = disc.file('$.!BOOT').parsed.data.values
      vals = lines.shift

      @date = Date.strptime(vals[1].tr('.', '/'), '%d/%m/%y')
                  .strftime('%d/%b/%Y')
      @menuid = 1

      convert_menu_data(lines)
      apply_tweaks

      @mapper.map(@menus, @disc.files)
    end

    def convert_menu_data(lines)
      until (vals = lines.shift).nil?
        menu = Menu.new
        menu.title = vals[0]
        entries = Integer(vals[1])

        menu.id = @menuid
        @menuid += 1

        entries.times do
          vals = lines.shift

          entry = MenuEntry.new
          entry.title = vals[0]
          entry.model = model_from_title(entry.title)
          entry.files = [[@disc.file("#{vals[1]}.#{vals[2]}")]] if vals[1] != ''

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
              throw "Unknown action type: #{action}"
            end
          end

          menu.entries << entry
        end

        @menus << menu
      end
    end
  end
end
