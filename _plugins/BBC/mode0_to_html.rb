module BBC
  module Mode0Filter
    def mode0_to_html(input)
      output = ''

      row = 0
      column = 0

      underline = false
      controlchar = false
      prevchar = -1

      input.each_byte do |c|
        if controlchar
          case c.chr
          when 'B'
            output << '<b>'
          when 'b'
            output << '</b>'
          when 'I'
            output << '<i>'
          when 'i'
            output << '</i>'
          when 'S'
            output << '<span class="super">'
          when 'W'
            output << '<span class="wide">'
          when 'Y'
            output << '<span class="subs">'
          when 's', 'w', 'y'
            output << '</span>'
          when '*'
            output << '<span class="inv">*</span>'
          else
            throw 'Unknown control character: "' + c.chr + '" (ascii ' + c.to_s + ') at line ' + row.to_s + ' column ' + column.to_s
          end

          controlchar = false
          next
        end

        case c
        when 0
          # EOF
          break
        when 9
          # Tab - conv to spaces in the same way as the 80 col scroller
          loop do
            if column > 79
              output << "\n"
              row += 1
              column == 0
            end

            output << ' '
            break if (column + 2) % 8 == 0
            column += 1
          end
        when 10
          # Line feed
          if column == 0
            column = 79
          else
            throw 'Implement line feeds not at the start of a line'
          end
        when 13
          # Carriage return
          # This displays as a line feed as well unless there has just
          # been one, in which when it has no effect
          if prevchar != 10
            column = 79
          else
            next
          end
        when 28
          if underline
            output << '</span>'
            underline = false
          else
            output << '<span class="uline">'
            underline = true
          end
        when 29
          controlchar = true
          next
        when 32..37
          # {space}!"#$%
          output << c.chr
        when 38
          output << '&amp;'
        when 39..59
          # '()*+,-./0-9:
          output << c.chr
        when 60
          output << '&lt;'
        when 61
          # =
          output << c.chr
        when 62
          output << '&gt;'
        when 63..95
          # ?@A-Z[\# ]^_
          output << c.chr
        when 96
          output << '£'
        when 97..126
          # a-z{|}~
          output << c.chr
        # Chars 128-254 display as spaces in the Micro, but are populated
        # with special characters by default in the Master.
        # As the Micro was more popular, display these as spaces.
        when 128..254
          output << ' '
        else
          output << '?'
          throw 'Unknown character value ' + c.to_s + ' at line ' + row.to_s + ' column ' + column.to_s
        end

        prevchar = c
        column += 1

        if column > 79
          output << "\n"
          row += 1
          column = 0
        end
      end

      output
    end
  end

  Liquid::Template.register_filter(BBC::Mode0Filter)
end
