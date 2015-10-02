module EBS
  class DiscReader < Disc
    def initialize(issue, imagepath)
      super(issue, imagepath)

      disc = BBC::DfsDisc.new(imagepath)
      data = disc.file('$.!BOOT')

      lines = read_data_lines(data.content)
      vals = lines.shift

      @date = Date.strptime(vals[1].tr('.', '/'), '%d/%m/%y')
      @menus = []
      @menuid = 1
      @linkpaths = {}

      while read_menu_data(lines, data.disc); end
    end

    def read_data_lines(data)
      lines = []
      pos = 0

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

        # Only a valid data line if first byte is the DATA token
        is_data_line = data.getbyte(pos) == 0xdc
        pos += 1

        if is_data_line
          line = data[pos..(pos + linelen - 1)]
          lines << line.strip.split(',')
        end

        pos += linelen - 1
      end

      lines
    end

    def read_menu_data(lines, disc)
      vals = lines.shift
      return false if vals.nil?

      menu = Menu.new
      menu.title = vals[0]
      entries = Integer(vals[1])

      menu.id = @menuid
      @menuid += 1

      entries.times do
        vals = lines.shift

        entry = MenuEntry.new(disc, @linkpaths)
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

        menu.entries << entry
      end

      @menus << menu

      true
    end
  end
end
