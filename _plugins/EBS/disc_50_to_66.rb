# frozen_string_literal: true

# Copyright © 2007-2024 Matt Robinson
#
# SPDX-License-Identifier: GPL-3.0-or-later

require_relative 'disc'

module EBS
  class Disc50To66 < Disc
    def initialize(site, issue, imagepath)
      super

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
