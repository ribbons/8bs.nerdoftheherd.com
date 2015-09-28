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

      # Entire length of line, so subtract bytes already read
      linelen = data.shift - 4

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
            line << inline_line_num(data).to_s
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

    private def inline_line_num(data)
      bytes = data.shift(3)
      result = bytes[1] - 0x40

      case bytes[0]
      when 0x54
        # Nothing to add
      when 0x44
        result += 64
      when 0x74
        result += 128
      when 0x64
        result += 192
      else
        throw 'Unexpected value ' + bytes[0].to_s + ' for byte 1 of inline number'
      end

      result + ((bytes[2] - 0x40) << 8)
    end
  end

  Liquid::Template.register_filter(BBC::BasicFilter)
end
