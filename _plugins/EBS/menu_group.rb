module EBS
  class MenuGroup < Liquid::Drop
    def initialize(discimg)
      disc = BBC::DfsDisc.new(discimg)
      data = disc.file('$.!BOOT').reader

      vals = read_data_line(data).split(',')

      @issuenum = vals[0]
      @date = Date.strptime(vals[1].tr('.', '/'), '%d/%m/%y')
      @menus = []
      @menuid = 1
      @linkpaths = {}

      while read_menu_data(data); end
    end

    attr_reader :issuenum, :date, :menus

    def read_data_line(data)
      loop do
        fail 'Malformed BBC BASIC file' if data.readbyte != 0x0d

        # End of file marker
        return nil if data.readbyte == 0xff

        # Skip second byte of line number
        data.readbyte

        # Entire length of line, so subtract bytes already read
        linelen = data.readbyte - 4

        # Only a valid data line if first byte is the DATA token
        is_data_line = data.readbyte == 0xdc

        if is_data_line
          line = ''

          (linelen - 1).times do
            line += data.readbyte.chr
          end

          return line.strip
        end

        # Read and discard the rest of the line
        (linelen - 1).times { data.readbyte }
      end
    end

    def read_menu_data(data)
      line = read_data_line(data)
      return false if line.nil?

      menu = Menu.new
      vals = line.split(',')

      menu.title = vals[0]
      entries = Integer(vals[1])

      menu.id = @menuid
      @menuid += 1

      entries.times do
        vals = read_data_line(data).split(',')

        entry = MenuEntry.new(data.disc)
        entry.title = vals[0]
        entry.path = vals[1] + '.' + vals[2] if vals[1] != ''

        action = vals[3]

        case action.to_i
        when 1..10
          # Another menu
          entry.type = :menu
          entry.id = action
        when -1
          # 80 Column Text
          entry.type = :mode0
        when -2
          # 40 Column Text
          entry.type = :mode7
        when -3
          # Archive
          throw 'Unimplemented type: Archive'
        when -4, -6
          # Basic Program / Lists BASIC
          entry.type = :basic
        when -5
          # Loads BASIC
          throw 'Unimplemented type: Loads BASIC'
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
            throw 'Unknown action type: ' + vals[3]
          end
        end

        if entry.type != :menu
          if @linkpaths.key?(entry.linkpath)
            if @linkpaths[entry.linkpath].path != entry.path
              throw 'Duplicate entry link path: ' + entry.linkpath
            end
          else
            @linkpaths[entry.linkpath] = entry
          end
        end

        menu.entries << entry
      end

      @menus << menu

      true
    end
  end
end
