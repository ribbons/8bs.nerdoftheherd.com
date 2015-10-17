module EBS
  class Disc28To49 < Disc
    def initialize(issue, imagepath)
      super(issue, imagepath)

      disc = BBC::DfsDisc.new(imagepath)
      file = disc.file('$.Menu')
      data = file.content

      dateval = read_str_var('m', data).strip
      @date = Date.strptime(dateval, '%d.%m.%y')

      id_mapping = read_id_map(data)
      lines = read_data_lines(data)
      convert_menu_data(lines, id_mapping, file.disc)
    end

    # The first version of the menu by S.Flintham includes 'PROCla' which takes
    # a menu number and then RESTOREs to the relevant data line.
    # Read these values and build a reverse lookup hash to convert line numbers
    # into menu numbers.
    private def read_id_map(data)
      map = {}
      pos = 0
      inproc = false

      loop do
        fail 'Malformed BBC BASIC file' if data.getbyte(pos) != 0x0d
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

          if linelen < 7 || data[pos..pos + 3] != "\xe7f%=".b || data[pos + 5..pos + 6] != "\x8c\xf7".b
            fail 'Unexpected line in PROC la'
          end

          pos += 4
          linelen -= 4

          menuid = data.getbyte(pos).chr

          if linelen == 3
            map[:first] = menuid
          else
            linenum = BBC::BasicFilter.inline_line_num(data[pos + 5..pos + 7].each_byte.to_a)
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

    private def convert_menu_data(lines, id_mapping, disc)
      entries = 0
      menu = nil
      first_paths = nil

      lines.each do |linenum, vals|
        if entries == 0
          if menu.nil?
            menuid = id_mapping[:first]
          else
            @menus << menu
            menuid = id_mapping[linenum]

            # Remove second+ paths which are the first path on another entry
            menu.entries.each do |entry|
              unless entry.paths.nil? || entry.paths.size == 1
                entry.paths.delete_if.with_index { |path, i| i > 0 && first_paths.include?(path) }
              end
            end
          end

          menu = Menu.new
          menu.title = vals[0]
          menu.id = menuid

          entries = vals[1].to_i
          first_paths = []
        else
          entry = MenuEntry.new(disc, @linkpaths)
          entry.title = vals[0]

          unless vals[2] == ''
            entry.paths = vals[3].split('@').each.map { |file| vals[2] + '.' + file }
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
              throw 'Unknown command \'' + command + '\' for \'' + entry.title + '\''
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
