module EBS
  class Disc0To49 < Disc
    def initialize(issue, imagepath)
      super(issue, imagepath)

      disc = BBC::DfsDisc.new(imagepath)
      file = disc.file('$.Menu')
      data = file.content

      dateval = read_str_var('m', data).strip
      @date = Date.strptime(dateval, '%d.%m.%y')

      @menuid = 1

      lines = read_data_lines(data)
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
          entry.path = vals[2] + '.' + vals[3] if vals[2] != ''

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
            else
              throw 'Unknown command \'' + command + '\' for \'' + entry.title + '\''
            end
          end

          menu.entries << entry
        end

        @menus << menu
      end
    end
  end
end
