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

require_relative 'disc'

module EBS
  class Disc28To49 < Disc
    def initialize(site, issue, imagepath)
      super(site, issue, imagepath)

      bootlines = disc.file('$.!Boot').content.split("\r")
      datevals = bootlines[6]
                 .match(/(?:([0-9]+)[A-Z]{2} )?([A-Z]{3})[A-Z]* ([0-9]{4})/i)
                 .captures

      @date = datevals[1..2].join('/')
      @date = datevals[0].rjust(2, '0') + '/' + @date unless datevals[0].nil?

      data = disc.file('$.Menu').content
      id_mapping = read_id_map(data)
      lines = read_data_lines(data)
      convert_menu_data(lines, id_mapping)
      apply_tweaks(imagepath)

      @mapper.map_menus(@menus)
    end

    private

    # The first version of the menu by S.Flintham includes 'PROCla' which takes
    # a menu number and then RESTOREs to the relevant data line.
    # Read these values and build a reverse lookup hash to convert line numbers
    # into menu numbers.
    def read_id_map(data)
      map = {}
      pos = 0
      inproc = false

      loop do
        raise 'Malformed BBC BASIC file' if data.getbyte(pos) != 0x0d

        pos += 1

        # End of file marker
        break if data.getbyte(pos) == 0xff

        # Skip second byte of line number
        pos += 2

        # Entire length of line, so subtract bytes already read
        linelen = data.getbyte(pos) - 4
        pos += 1

        if inproc
          if linelen == 1 && data.getbyte(pos) == 0xe1
            # ENDPROC
            break
          end

          if linelen < 7 || data[pos..pos + 3] != "\xe7f%=".b ||
             data[pos + 5..pos + 6] != "\x8c\xf7".b
            raise 'Unexpected line in PROC la'
          end

          pos += 4
          linelen -= 4

          menuid = data.getbyte(pos).chr.to_i

          if linelen == 3
            map[:first] = menuid unless map.key?(:first)
          else
            numpos = data.getbyte(pos + 4) == 0x8d ? pos + 5 : pos + 4
            linenum = BBC::BasicFilter.inline_line_num(data[numpos..numpos + 2]
                                      .each_byte.to_a)
            map[linenum] = menuid
          end
        elsif linelen == 8 && data[pos..pos + 7] == "\xdd\xf2la(f%)".b
          # Found DEFPROCla(f%)
          inproc = true
        end

        pos += linelen
      end

      map
    end

    def convert_menu_data(lines, id_mapping)
      entries = 0
      menu = nil
      first_paths = nil

      lines.each do |linenum, vals|
        if entries.zero?
          menuid = id_mapping[linenum]

          if menu.nil?
            menuid = id_mapping[:first] if menuid.nil?
          else
            @menus << menu

            # Remove second+ paths which are the first path on another entry
            menu.entries.each do |entry|
              next if entry.paths.nil? || entry.paths.size == 1

              entry.paths.delete_if.with_index do |path, i|
                i.positive? && first_paths.include?(path)
              end
            end
          end

          menu = Menu.new
          menu.title = vals[0]
          menu.id = menuid

          entries = vals[1].to_i
          first_paths = []
        else
          entry = MenuEntry.new(self)
          entry.title = vals[0]
          entry.model = model_from_title(entry.title)

          unless vals[3] == ''
            entry.paths = vals[3].split('@').each.map do |file|
              vals[2] + '.' + file
            end

            first_paths << entry.paths.first
          end

          command = vals[1]
          is_text = vals[4].to_i == -1
          is_mode7 = vals[5].to_i == -1
          menuid = vals[6].to_i

          if menuid != 0
            entry.type = :menu
            entry.id = menuid
          elsif is_text && !is_mode7
            entry.type = :mode0
          elsif is_text && is_mode7
            entry.type = :mode7
          else
            case command.upcase
            when '*RUN'
              entry.type = :run
            when 'CHAIN'
              entry.type = :basic
            when '*EX.'
              entry.type = :exec
            else
              throw 'Unknown command \'' + command + '\' for \'' +
                    entry.title + '\''
            end
          end

          menu.entries << entry
          entries -= 1
        end
      end

      @menus << menu
    end
  end
end
