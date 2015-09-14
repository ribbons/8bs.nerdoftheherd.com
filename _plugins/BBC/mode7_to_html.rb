module BBC
  module Mode7Filter
    module Colour
      BLACK = 0
      RED = 1
      GREEN = 2
      YELLOW = 3
      BLUE = 4
      MAGENTA = 5
      CYAN = 6
      WHITE = 7
    end

    module Offsets
      TXT_DBL_UPPER = 0xE000
      TXT_DBL_LOWER = 0xE100
      GFX_CONTIG = 0xE200
      GFX_SEPARA = 0xE2C0
    end

    def mode7_to_html(input)
      # Chop off scroller code
      input = input[256..-1]

      row = 0
      column = 0
      mode = :text
      flash = :steady
      forecolour = nextfore = Colour::WHITE
      backcolour = Colour::BLACK
      graphicsmode = :contig
      height = :standard
      graphicshold = :release
      concealed = :reveal

      charlines = []
      htmllines = []

      charline = []
      htmlline = []

      input.each_byte do |c|
        if forecolour != nextfore
          forecolour = nextfore
          stylechange = true
        else
          stylechange = false
        end

        case c
        when 0
          # Null byte - assume that the end of the file has been reached
          break
        when 13
          column = 39
        when 128, 138, 139, 142, 143, 144
          # 'Nothing' in the user guide - displays as a space
          charline << '&nbsp;'
        when 32, 160
          charline << '&nbsp;'
        when 33, 161
          if mode == :text
            charline << textval('!', height, charlines, column)
          else
            charline << graphval(1, graphicsmode)
          end
        when 34, 162
          if mode == :text
            charline << textval('"', height, charlines, column)
          else
            charline << graphval(2, graphicsmode)
          end
        when 35, 163
          if mode == :text
            charline << '£'
          else
            charline << graphval(3, graphicsmode)
          end
        when 36, 164
          if mode == :text
            charline << textval('$', height, charlines, column)
          else
            charline << graphval(4, graphicsmode)
          end
        when 37, 165
          if mode == :text
            charline << textval('%', height, charlines, column)
          else
            charline << graphval(5, graphicsmode)
          end
        when 38, 166
          if mode == :text
            charline << textval('&', height, charlines, column)
          else
            charline << graphval(6, graphicsmode)
          end
        when 39, 167
          if mode == :text
            charline << textval('\'', height, charlines, column)
          else
            charline << graphval(7, graphicsmode)
          end
        when 40, 168
          if mode == :text
            charline << textval('(', height, charlines, column)
          else
            charline << graphval(8, graphicsmode)
          end
        when 41, 169
          if mode == :text
            charline << textval(')', height, charlines, column)
          else
            charline << graphval(9, graphicsmode)
          end
        when 42, 170
          if mode == :text
            charline << textval('*', height, charlines, column)
          else
            charline << graphval(10, graphicsmode)
          end
        when 43, 171
          if mode == :text
            charline << textval('+', height, charlines, column)
          else
            charline << graphval(11, graphicsmode)
          end
        when 44, 172
          if mode == :text
            charline << textval(',', height, charlines, column)
          else
            charline << graphval(12, graphicsmode)
          end
        when 45, 173
          if mode == :text
            charline << textval('-', height, charlines, column)
          else
            charline << graphval(13, graphicsmode)
          end
        when 46, 174
          if mode == :text
            charline << textval('.', height, charlines, column)
          else
            charline << graphval(14, graphicsmode)
          end
        when 47, 175
          if mode == :text
            charline << textval('/', height, charlines, column)
          else
            charline << graphval(15, graphicsmode)
          end
        when 48, 176
          if mode == :text
            charline << textval('0', height, charlines, column)
          else
            charline << graphval(16, graphicsmode)
          end
        when 49, 177
          if mode == :text
            charline << textval('1', height, charlines, column)
          else
            charline << graphval(17, graphicsmode)
          end
        when 50, 178
          if mode == :text
            charline << textval('2', height, charlines, column)
          else
            charline << graphval(18, graphicsmode)
          end
        when 51, 179
          if mode == :text
            charline << textval('3', height, charlines, column)
          else
            charline << graphval(19, graphicsmode)
          end
        when 52, 180
          if mode == :text
            charline << textval('4', height, charlines, column)
          else
            charline << graphval(20, graphicsmode)
          end
        when 53, 181
          if mode == :text
            charline << textval('5', height, charlines, column)
          else
            charline << graphval(21, graphicsmode)
          end
        when 54, 182
          if mode == :text
            charline << textval('6', height, charlines, column)
          else
            charline << graphval(22, graphicsmode)
          end
        when 55, 183
          if mode == :text
            charline << textval('7', height, charlines, column)
          else
            charline << graphval(23, graphicsmode)
          end
        when 56, 184
          if mode == :text
            charline << textval('8', height, charlines, column)
          else
            charline << graphval(24, graphicsmode)
          end
        when 57, 185
          if mode == :text
            charline << textval('9', height, charlines, column)
          else
            charline << graphval(25, graphicsmode)
          end
        when 58, 186
          if mode == :text
            charline << textval(':', height, charlines, column)
          else
            charline << graphval(26, graphicsmode)
          end
        when 59, 187
          if mode == :text
            charline << textval(';', height, charlines, column)
          else
            charline << graphval(27, graphicsmode)
          end
        when 60, 188
          if mode == :text
            charline << textval('<', height, charlines, column)
          else
            charline << graphval(28, graphicsmode)
          end
        when 61, 189
          if mode == :text
            charline << textval('=', height, charlines, column)
          else
            charline << graphval(29, graphicsmode)
          end
        when 62, 190
          if mode == :text
            charline << textval('>', height, charlines, column)
          else
            charline << graphval(30, graphicsmode)
          end
        when 63, 191
          if mode == :text
            charline << textval('?', height, charlines, column)
          else
            charline << graphval(31, graphicsmode)
          end
        when 64, 192
          charline << textval('@', height, charlines, column)
        when 65, 193
          charline << textval('A', height, charlines, column)
        when 66, 194
          charline << textval('B', height, charlines, column)
        when 67, 195
          charline << textval('C', height, charlines, column)
        when 68, 196
          charline << textval('D', height, charlines, column)
        when 69, 197
          charline << textval('E', height, charlines, column)
        when 70, 198
          charline << textval('F', height, charlines, column)
        when 71, 199
          charline << textval('G', height, charlines, column)
        when 72, 200
          charline << textval('H', height, charlines, column)
        when 73, 201
          charline << textval('I', height, charlines, column)
        when 74, 202
          charline << textval('J', height, charlines, column)
        when 75, 203
          charline << textval('K', height, charlines, column)
        when 76, 204
          charline << textval('L', height, charlines, column)
        when 77, 205
          charline << textval('M', height, charlines, column)
        when 78, 206
          charline << textval('N', height, charlines, column)
        when 79, 207
          charline << textval('O', height, charlines, column)
        when 80, 208
          charline << textval('P', height, charlines, column)
        when 81, 209
          charline << textval('Q', height, charlines, column)
        when 82, 210
          charline << textval('R', height, charlines, column)
        when 83, 211
          charline << textval('S', height, charlines, column)
        when 84, 212
          charline << textval('T', height, charlines, column)
        when 85, 213
          charline << textval('U', height, charlines, column)
        when 86, 214
          charline << textval('V', height, charlines, column)
        when 87, 215
          charline << textval('W', height, charlines, column)
        when 88, 216
          charline << textval('X', height, charlines, column)
        when 89, 217
          charline << textval('Y', height, charlines, column)
        when 90, 218
          charline << textval('Z', height, charlines, column)
        when 91, 219
          charline << textval('[', height, charlines, column)
        when 92, 220
          charline << textval('½', height, charlines, column)
        when 93, 221
          charline << textval(']', height, charlines, column)
        when 94, 222
          charline << textval('^', height, charlines, column)
        when 95, 223
          charline << textval('#', height, charlines, column)
        when 96, 224
          if mode == :text
            charline << textval('_', height, charlines, column)
          else
            charline << graphval(32, graphicsmode)
          end
        when 97, 225
          if mode == :text
            charline << textval('a', height, charlines, column)
          else
            charline << graphval(33, graphicsmode)
          end
        when 98, 226
          if mode == :text
            charline << textval('b', height, charlines, column)
          else
            charline << graphval(34, graphicsmode)
          end
        when 99, 227
          if mode == :text
            charline << textval('c', height, charlines, column)
          else
            charline << graphval(35, graphicsmode)
          end
        when 100, 228
          if mode == :text
            charline << textval('d', height, charlines, column)
          else
            charline << graphval(36, graphicsmode)
          end
        when 101, 229
          if mode == :text
            charline << textval('e', height, charlines, column)
          else
            charline << graphval(37, graphicsmode)
          end
        when 102, 230
          if mode == :text
            charline << textval('f', height, charlines, column)
          else
            charline << graphval(38, graphicsmode)
          end
        when 103, 231
          if mode == :text
            charline << textval('g', height, charlines, column)
          else
            charline << graphval(39, graphicsmode)
          end
        when 104, 232
          if mode == :text
            charline << textval('h', height, charlines, column)
          else
            charline << graphval(40, graphicsmode)
          end
        when 105, 233
          if mode == :text
            charline << textval('i', height, charlines, column)
          else
            charline << graphval(41, graphicsmode)
          end
        when 106, 234
          if mode == :text
            charline << textval('j', height, charlines, column)
          else
            charline << graphval(42, graphicsmode)
          end
        when 107, 235
          if mode == :text
            charline << textval('k', height, charlines, column)
          else
            charline << graphval(43, graphicsmode)
          end
        when 108, 236
          if mode == :text
            charline << textval('l', height, charlines, column)
          else
            charline << graphval(44, graphicsmode)
          end
        when 109, 237
          if mode == :text
            charline << textval('m', height, charlines, column)
          else
            charline << graphval(45, graphicsmode)
          end
        when 110, 238
          if mode == :text
            charline << textval('n', height, charlines, column)
          else
            charline << graphval(46, graphicsmode)
          end
        when 111, 239
          if mode == :text
            charline << textval('o', height, charlines, column)
          else
            charline << graphval(47, graphicsmode)
          end
        when 112, 240
          if mode == :text
            charline << textval('p', height, charlines, column)
          else
            charline << graphval(48, graphicsmode)
          end
        when 113, 241
          if mode == :text
            charline << textval('q', height, charlines, column)
          else
            charline << graphval(49, graphicsmode)
          end
        when 114, 242
          if mode == :text
            charline << textval('r', height, charlines, column)
          else
            charline << graphval(50, graphicsmode)
          end
        when 115, 243
          if mode == :text
            charline << textval('s', height, charlines, column)
          else
            charline << graphval(51, graphicsmode)
          end
        when 116, 244
          if mode == :text
            charline << textval('t', height, charlines, column)
          else
            charline << graphval(52, graphicsmode)
          end
        when 117, 245
          if mode == :text
            charline << textval('u', height, charlines, column)
          else
            charline << graphval(53, graphicsmode)
          end
        when 118, 246
          if mode == :text
            charline << textval('v', height, charlines, column)
          else
            charline << graphval(54, graphicsmode)
          end
        when 119, 247
          if mode == :text
            charline << textval('w', height, charlines, column)
          else
            charline << graphval(55, graphicsmode)
          end
        when 120, 248
          if mode == :text
            charline << textval('x', height, charlines, column)
          else
            charline << graphval(56, graphicsmode)
          end
        when 121, 249
          if mode == :text
            charline << textval('y', height, charlines, column)
          else
            charline << graphval(57, graphicsmode)
          end
        when 122, 250
          if mode == :text
            charline << textval('z', height, charlines, column)
          else
            charline << graphval(58, graphicsmode)
          end
        when 123, 251
          if mode == :text
            charline << textval('¼', height, charlines, column)
          else
            charline << graphval(59, graphicsmode)
          end
        when 124, 252
          if mode == :text
            charline << textval('|', height, charlines, column)
          else
            charline << graphval(60, graphicsmode)
          end
        when 125, 253
          if mode == :text
            charline << textval('¾', height, charlines, column)
          else
            charline << graphval(61, graphicsmode)
          end
        when 126, 254
          if mode == :text
            charline << textval('~', height, charlines, column)
          else
            charline << graphval(62, graphicsmode)
          end
        when 127, 255
          charline << graphval(63, graphicsmode)
        when 129
          if graphicshold == :hold && charline.last.ord > Offsets::GFX_CONTIG
            throw 'Check if held graphics would be valid here'
          end

          charline << '&nbsp;'
          mode = :text
          nextfore = Colour::RED
          concealed = :reveal
        when 130
          if graphicshold == :hold && charline.last.ord > Offsets::GFX_CONTIG
            throw 'Check if held graphics would be valid here'
          end

          charline << '&nbsp;'
          mode = :text
          nextfore = Colour::GREEN
          concealed = :reveal
        when 131
          if graphicshold == :hold && charline.last.ord > Offsets::GFX_CONTIG
            throw 'Check if held graphics would be valid here'
          end

          charline << '&nbsp;'
          mode = :text
          nextfore = Colour::YELLOW
          concealed = :reveal
        when 132
          if graphicshold == :hold && charline.last.ord > Offsets::GFX_CONTIG
            throw 'Check if held graphics would be valid here'
          end

          charline << '&nbsp;'
          mode = :text
          nextfore = Colour::BLUE
          concealed = :reveal
        when 133
          if graphicshold == :hold && charline.last.ord > Offsets::GFX_CONTIG
            throw 'Check if held graphics would be valid here'
          end

          charline << '&nbsp;'
          mode = :text
          nextfore = Colour::MAGENTA
          concealed = :reveal
        when 134
          if graphicshold == :hold && charline.last.ord > Offsets::GFX_CONTIG
            throw 'Check if held graphics would be valid here'
          end

          charline << '&nbsp;'
          mode = :text
          nextfore = Colour::CYAN
          concealed = :reveal
        when 135
          if graphicshold == :hold && charline.last.ord > Offsets::GFX_CONTIG
            throw 'Check if held graphics would be valid here'
          end

          charline << '&nbsp;'
          mode = :text
          nextfore = Colour::WHITE
          concealed = :reveal
        when 136
          if graphicshold == :hold && charline.last.ord > Offsets::GFX_CONTIG
            throw 'Check if held graphics would be valid here'
          end

          charline << '&nbsp;'
          flash = :flash
          stylechange = true
        when 137
          if graphicshold == :hold && charline.last.ord > Offsets::GFX_CONTIG
            throw 'Check if held graphics would be valid here'
          end

          charline << '&nbsp;'
          flash = :steady
          stylechange = true
        when 140
          if graphicshold == :hold && charline.last.ord > Offsets::GFX_CONTIG
            throw 'Check if held graphics would be valid here'
          end

          charline << '&nbsp;'
          height = :standard
        when 141
          if graphicshold == :hold && charline.last.ord > Offsets::GFX_CONTIG
            throw 'Check if held graphics would be valid here'
          end

          charline << '&nbsp;'
          height = :double
        when 145
          if graphicshold == :hold && charline.last.ord > Offsets::GFX_CONTIG
            charline << charline.last
          else
            charline << '&nbsp;'
          end

          mode = :graphics
          nextfore = Colour::RED
          concealed = :reveal
        when 146
          if graphicshold == :hold && charline.last.ord > Offsets::GFX_CONTIG
            charline << charline.last
          else
            charline << '&nbsp;'
          end

          mode = :graphics
          nextfore = Colour::GREEN
          concealed = :reveal
        when 147
          if graphicshold == :hold && charline.last.ord > Offsets::GFX_CONTIG
            charline << charline.last
          else
            charline << '&nbsp;'
          end

          mode = :graphics
          nextfore = Colour::YELLOW
          concealed = :reveal
        when 148
          if graphicshold == :hold && charline.last.ord > Offsets::GFX_CONTIG
            charline << charline.last
          else
            charline << '&nbsp;'
          end

          mode = :graphics
          nextfore = Colour::BLUE
          concealed = :reveal
        when 149
          if graphicshold == :hold && charline.last.ord > Offsets::GFX_CONTIG
            charline << charline.last
          else
            charline << '&nbsp;'
          end

          mode = :graphics
          nextfore = Colour::MAGENTA
          concealed = :reveal
        when 150
          if graphicshold == :hold && charline.last.ord > Offsets::GFX_CONTIG
            charline << charline.last
          else
            charline << '&nbsp;'
          end

          mode = :graphics
          nextfore = Colour::CYAN
          concealed = :reveal
        when 151
          if graphicshold == :hold && charline.last.ord > Offsets::GFX_CONTIG
            charline << charline.last
          else
            charline << '&nbsp;'
          end

          mode = :graphics
          nextfore = Colour::WHITE
          concealed = :reveal
        when 152
          if graphicshold == :hold && charline.last.ord > Offsets::GFX_CONTIG
            throw 'Check if held graphics would be valid here'
          end

          charline << '&nbsp;'
          concealed = :conceal
        when 153
          if graphicshold == :hold && charline.last.ord > Offsets::GFX_CONTIG
            throw 'Check if held graphics would be valid here'
          end

          charline << '&nbsp;'
          graphicsmode = :contig
        when 154
          if graphicshold == :hold && charline.last.ord > Offsets::GFX_CONTIG
            throw 'Check if held graphics would be valid here'
          end

          charline << '&nbsp;'
          graphicsmode = :separa
        when 156
          if graphicshold == :hold && charline.last.ord > Offsets::GFX_CONTIG
            throw 'Check if held graphics would be valid here'
          end

          charline << '&nbsp;'
          backcolour = Colour::BLACK
          stylechange = true
        when 157
          if graphicshold == :hold && charline.last.ord > Offsets::GFX_CONTIG
            throw 'Check if held graphics would be valid here'
          end

          charline << '&nbsp;'
          backcolour = forecolour
          stylechange = true
        when 158
          if graphicshold == :hold && charline.last.ord > Offsets::GFX_CONTIG
            charline << charline.last
          else
            charline << '&nbsp;'
          end

          graphicshold = :hold if mode == :graphics
        when 159
          if graphicshold == :hold && charline.last.ord > Offsets::GFX_CONTIG
            throw 'Check if held graphics would be valid here'
          end

          graphicshold = :release
        else
          throw 'Unknown character value ' + c.to_s + ' at line ' + row.to_s + ' column ' + column.to_s
        end

        if concealed == :conceal && charline.last != '&nbsp;'
          throw 'Concealed graphics would have affected output at line ' + row.to_s + ' column ' + column.to_s
        end

        html = ''

        if stylechange
          classes = []
          classes << 't' + forecolour.to_s if forecolour != Colour::WHITE
          classes << 'b' + backcolour.to_s if backcolour != Colour::BLACK
          classes << 'flash' if flash == :flash

          html << '</span><span class="' + classes.join(' ') + '">'
        end

        htmlline << html

        column += 1

        if column > 39
          column = 0
          row += 1
          mode = :text
          flash = :steady
          forecolour = nextfore = Colour::WHITE
          backcolour = Colour::BLACK
          graphicsmode = :contig
          height = :standard
          graphicshold = :release

          charline << ''
          charlines << charline
          charline = []

          htmlline << '<br>'
          htmllines << htmlline
          htmlline = []
        end
      end

      output = ''

      charlines.each_index do |linesidx|
        htmlline = htmllines[linesidx]
        charline = charlines[linesidx]

        output << '<span>'

        charline.each_index do |lineidx|
          html = htmlline[lineidx]
          char = charline[lineidx]

          output << html << char
        end

        output << '</span>'
      end

      output
    end

    private def graphval(value, mode)
      if mode == :contig
        charval = Offsets::GFX_CONTIG + value
      else
        charval = Offsets::GFX_SEPARA + value
      end

      [charval].pack('U')
    end

    private def textval(char, height, charlines, column)
      if height == :standard
        case char
        when '<'
          return '&lt;'
        when '>'
          return '&gt;'
        when '&'
          return '&amp;'
        else
          return char
        end
      end

      unless charlines.last.nil? || charlines.last[column].nil?
        if charlines.last[column][0].ord.between?(Offsets::TXT_DBL_UPPER, Offsets::TXT_DBL_LOWER - 1)
          return [Offsets::TXT_DBL_LOWER + char.ord].pack('U')
        end
      end

      [Offsets::TXT_DBL_UPPER + char.ord].pack('U')
    end
  end

  Liquid::Template.register_filter(BBC::Mode7Filter)
end
