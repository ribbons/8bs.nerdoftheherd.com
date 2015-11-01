# This file is part of the 8BS Online Conversion.
# Copyright © 2015 by the authors - see the AUTHORS file for details.
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

module BBC
  module BasicFilter
    TOKENS = { 0x80 => 'AND', 0x81 => 'DIV', 0x82 => 'EOR', 0x83 => 'MOD', 0x84 => 'OR',
               0x85 => 'ERROR', 0x86 => 'LINE', 0x87 => 'OFF', 0x88 => 'STEP', 0x89 => 'SPC',
               0x8A => 'TAB(', 0x8B => 'ELSE', 0x8C => 'THEN', 0x8E => 'OPENIN', 0x8F => 'PTR',
               0x90 => 'PAGE', 0x91 => 'TIME', 0x92 => 'LOMEM', 0x93 => 'HIMEM', 0x94 => 'ABS',
               0x95 => 'ACS', 0x96 => 'ADVAL', 0x97 => 'ASC', 0x98 => 'ASN', 0x99 => 'ATN',
               0x9A => 'BGET', 0x9B => 'COS', 0x9C => 'COUNT', 0x9D => 'DEG', 0x9E => 'ERL',
               0x9F => 'ERR', 0xA0 => 'EVAL', 0xA1 => 'EXP', 0xA2 => 'EXT', 0xA3 => 'FALSE',
               0xA4 => 'FN', 0xA5 => 'GET', 0xA6 => 'INKEY', 0xA7 => 'INSTR(', 0xA8 => 'INT',
               0xA9 => 'LEN', 0xAA => 'LN', 0xAB => 'LOG', 0xAC => 'NOT', 0xAD => 'OPENUP',
               0xAE => 'OPENOUT', 0xAF => 'PI', 0xB0 => 'POINT(', 0xB1 => 'POS', 0xB2 => 'RAD',
               0xB3 => 'RND', 0xB4 => 'SGN', 0xB5 => 'SIN', 0xB6 => 'SQR', 0xB7 => 'TAN',
               0xB8 => 'TO', 0xB9 => 'TRUE', 0xBA => 'USR', 0xBB => 'VAL', 0xBC => 'VPOS',
               0xBD => 'CHR$', 0xBE => 'GET$', 0xBF => 'INKEY$', 0xC0 => 'LEFT$(', 0xC1 => 'MID$(',
               0xC2 => 'RIGHT$(', 0xC3 => 'STR$', 0xC4 => 'STRING$(', 0xC5 => 'EOF', 0xC6 => 'AUTO',
               0xC7 => 'DELETE', 0xC8 => 'LOAD', 0xC9 => 'LIST', 0xCA => 'NEW', 0xCB => 'OLD',
               0xCC => 'RENUMBER', 0xCD => 'SAVE', 0xCF => 'PTR', 0xD0 => 'PAGE', 0xD1 => 'TIME',
               0xD2 => 'LOMEM', 0xD3 => 'HIMEM', 0xD4 => 'SOUND', 0xD5 => 'BPUT', 0xD6 => 'CALL',
               0xD7 => 'CHAIN', 0xD8 => 'CLEAR', 0xD9 => 'CLOSE', 0xDA => 'CLG', 0xDB => 'CLS',
               0xDC => 'DATA', 0xDD => 'DEF', 0xDE => 'DIM', 0xDF => 'DRAW', 0xE0 => 'END',
               0xE1 => 'ENDPROC', 0xE2 => 'ENVELOPE', 0xE3 => 'FOR', 0xE4 => 'GOSUB', 0xE5 => 'GOTO',
               0xE6 => 'GCOL', 0xE7 => 'IF', 0xE8 => 'INPUT', 0xE9 => 'LET', 0xEA => 'LOCAL',
               0xEB => 'MODE', 0xEC => 'MOVE', 0xED => 'NEXT', 0xEE => 'ON', 0xEF => 'VDU',
               0xF0 => 'PLOT', 0xF1 => 'PRINT', 0xF2 => 'PROC', 0xF3 => 'READ', 0xF4 => 'REM',
               0xF5 => 'REPEAT', 0xF6 => 'REPORT', 0xF7 => 'RESTORE', 0xF8 => 'RETURN', 0xF9 => 'RUN',
               0xFA => 'STOP', 0xFB => 'COLOUR', 0xFC => 'TRACE', 0xFD => 'UNTIL', 0xFE => 'WIDTH',
               0xFF => 'OSCLI' }

    def basic_to_text(input)
      data = input.each_byte.to_a

      output = ''

      while (line = convert_line(data))
        output << line
      end

      output
    end

    private def convert_line(data)
      fail 'Malformed BBC BASIC file' if data.shift != 0x0d

      # End of file marker is 0xff
      return nil if (byte1 = data.shift) == 0xff

      line_num = (byte1 << 8) | data.shift

      linelen = data.shift
      return nil if linelen.nil?

      # Entire length of line, so subtract bytes already read
      linelen -= 4

      line = line_num.to_s.rjust(5)
      in_quotes = false
      in_remark = false

      while linelen > 0
        value = data.shift
        linelen -= 1

        # Ignore listing tricks which only work on a BBC
        case value
        when 0x07 # Beep
          next
        when 0x08 # Back
          # Probably hiding line numbers or code
          next
        when 0x0c # Clear screen
          next
        when 0x0e # Paged mode
          next
        when 0x15 # Disable VDU
          next
        when 0x16 # Set Mode
          # Also uses the value of the next byte
          data.shift
          linelen -= 1
          next
        end

        if in_remark
          line << value.chr
          next
        end

        in_quotes = !in_quotes if value == 0x22

        if (value > 0x7f) && (!in_quotes)
          if value == 0x8d # In-line line number
            line << BasicFilter.inline_line_num(data).to_s
            linelen -= 3
          elsif TOKENS.key?(value)
            line << TOKENS[value]
            in_remark = true if value == 0xf4
          else
            throw 'Unknown token value: ' + value.to_s
          end
        else
          line << value.chr
        end
      end

      line + "\r"
    end

    def self.inline_line_num(data)
      bits = data.shift << 2   # Shift the top two bits of LSB to top of byte
      top = bits & 0xc0        # Isolate top two bits
      lsb = top ^ data.shift   # EOR with next byte to form the LSB

      top = (bits << 2) & 0xc0 # Isolate top two bits of MSB at top of byte
      msb = top ^ data.shift   # Calculate the value of the MSB

      lsb | (msb << 8)
    end
  end

  Liquid::Template.register_filter(BBC::BasicFilter)
end
