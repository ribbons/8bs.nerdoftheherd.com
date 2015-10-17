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
