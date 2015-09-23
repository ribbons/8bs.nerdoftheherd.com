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
      row = 0
      column = 0
      spanopen = false

      mode = :text
      flash = :steady
      forecolour = nextfore = Colour::WHITE
      backcolour = Colour::BLACK
      graphicsmode = :contig
      height = :standard
      graphicshold = :release
      concealed = :reveal

      htmllines = []

      prevline = []
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
          thischar = ' '
        when 32, 160
          thischar = ' '
        when 33, 161
          if mode == :text
            thischar = textval('!', height, prevline, column)
          else
            thischar = graphval(1, graphicsmode)
          end
        when 34, 162
          if mode == :text
            thischar = textval('"', height, prevline, column)
          else
            thischar = graphval(2, graphicsmode)
          end
        when 35, 163
          if mode == :text
            thischar = '£'
          else
            thischar = graphval(3, graphicsmode)
          end
        when 36, 164
          if mode == :text
            thischar = textval('$', height, prevline, column)
          else
            thischar = graphval(4, graphicsmode)
          end
        when 37, 165
          if mode == :text
            thischar = textval('%', height, prevline, column)
          else
            thischar = graphval(5, graphicsmode)
          end
        when 38, 166
          if mode == :text
            thischar = textval('&', height, prevline, column)
          else
            thischar = graphval(6, graphicsmode)
          end
        when 39, 167
          if mode == :text
            thischar = textval('\'', height, prevline, column)
          else
            thischar = graphval(7, graphicsmode)
          end
        when 40, 168
          if mode == :text
            thischar = textval('(', height, prevline, column)
          else
            thischar = graphval(8, graphicsmode)
          end
        when 41, 169
          if mode == :text
            thischar = textval(')', height, prevline, column)
          else
            thischar = graphval(9, graphicsmode)
          end
        when 42, 170
          if mode == :text
            thischar = textval('*', height, prevline, column)
          else
            thischar = graphval(10, graphicsmode)
          end
        when 43, 171
          if mode == :text
            thischar = textval('+', height, prevline, column)
          else
            thischar = graphval(11, graphicsmode)
          end
        when 44, 172
          if mode == :text
            thischar = textval(',', height, prevline, column)
          else
            thischar = graphval(12, graphicsmode)
          end
        when 45, 173
          if mode == :text
            thischar = textval('-', height, prevline, column)
          else
            thischar = graphval(13, graphicsmode)
          end
        when 46, 174
          if mode == :text
            thischar = textval('.', height, prevline, column)
          else
            thischar = graphval(14, graphicsmode)
          end
        when 47, 175
          if mode == :text
            thischar = textval('/', height, prevline, column)
          else
            thischar = graphval(15, graphicsmode)
          end
        when 48, 176
          if mode == :text
            thischar = textval('0', height, prevline, column)
          else
            thischar = graphval(16, graphicsmode)
          end
        when 49, 177
          if mode == :text
            thischar = textval('1', height, prevline, column)
          else
            thischar = graphval(17, graphicsmode)
          end
        when 50, 178
          if mode == :text
            thischar = textval('2', height, prevline, column)
          else
            thischar = graphval(18, graphicsmode)
          end
        when 51, 179
          if mode == :text
            thischar = textval('3', height, prevline, column)
          else
            thischar = graphval(19, graphicsmode)
          end
        when 52, 180
          if mode == :text
            thischar = textval('4', height, prevline, column)
          else
            thischar = graphval(20, graphicsmode)
          end
        when 53, 181
          if mode == :text
            thischar = textval('5', height, prevline, column)
          else
            thischar = graphval(21, graphicsmode)
          end
        when 54, 182
          if mode == :text
            thischar = textval('6', height, prevline, column)
          else
            thischar = graphval(22, graphicsmode)
          end
        when 55, 183
          if mode == :text
            thischar = textval('7', height, prevline, column)
          else
            thischar = graphval(23, graphicsmode)
          end
        when 56, 184
          if mode == :text
            thischar = textval('8', height, prevline, column)
          else
            thischar = graphval(24, graphicsmode)
          end
        when 57, 185
          if mode == :text
            thischar = textval('9', height, prevline, column)
          else
            thischar = graphval(25, graphicsmode)
          end
        when 58, 186
          if mode == :text
            thischar = textval(':', height, prevline, column)
          else
            thischar = graphval(26, graphicsmode)
          end
        when 59, 187
          if mode == :text
            thischar = textval(';', height, prevline, column)
          else
            thischar = graphval(27, graphicsmode)
          end
        when 60, 188
          if mode == :text
            thischar = textval('<', height, prevline, column)
          else
            thischar = graphval(28, graphicsmode)
          end
        when 61, 189
          if mode == :text
            thischar = textval('=', height, prevline, column)
          else
            thischar = graphval(29, graphicsmode)
          end
        when 62, 190
          if mode == :text
            thischar = textval('>', height, prevline, column)
          else
            thischar = graphval(30, graphicsmode)
          end
        when 63, 191
          if mode == :text
            thischar = textval('?', height, prevline, column)
          else
            thischar = graphval(31, graphicsmode)
          end
        when 64, 192
          thischar = textval('@', height, prevline, column)
        when 65, 193
          thischar = textval('A', height, prevline, column)
        when 66, 194
          thischar = textval('B', height, prevline, column)
        when 67, 195
          thischar = textval('C', height, prevline, column)
        when 68, 196
          thischar = textval('D', height, prevline, column)
        when 69, 197
          thischar = textval('E', height, prevline, column)
        when 70, 198
          thischar = textval('F', height, prevline, column)
        when 71, 199
          thischar = textval('G', height, prevline, column)
        when 72, 200
          thischar = textval('H', height, prevline, column)
        when 73, 201
          thischar = textval('I', height, prevline, column)
        when 74, 202
          thischar = textval('J', height, prevline, column)
        when 75, 203
          thischar = textval('K', height, prevline, column)
        when 76, 204
          thischar = textval('L', height, prevline, column)
        when 77, 205
          thischar = textval('M', height, prevline, column)
        when 78, 206
          thischar = textval('N', height, prevline, column)
        when 79, 207
          thischar = textval('O', height, prevline, column)
        when 80, 208
          thischar = textval('P', height, prevline, column)
        when 81, 209
          thischar = textval('Q', height, prevline, column)
        when 82, 210
          thischar = textval('R', height, prevline, column)
        when 83, 211
          thischar = textval('S', height, prevline, column)
        when 84, 212
          thischar = textval('T', height, prevline, column)
        when 85, 213
          thischar = textval('U', height, prevline, column)
        when 86, 214
          thischar = textval('V', height, prevline, column)
        when 87, 215
          thischar = textval('W', height, prevline, column)
        when 88, 216
          thischar = textval('X', height, prevline, column)
        when 89, 217
          thischar = textval('Y', height, prevline, column)
        when 90, 218
          thischar = textval('Z', height, prevline, column)
        when 91, 219
          thischar = textval('[', height, prevline, column)
        when 92, 220
          thischar = textval('½', height, prevline, column)
        when 93, 221
          thischar = textval(']', height, prevline, column)
        when 94, 222
          thischar = textval('^', height, prevline, column)
        when 95, 223
          thischar = textval('#', height, prevline, column)
        when 96, 224
          if mode == :text
            thischar = textval('`', height, prevline, column)
          else
            thischar = graphval(32, graphicsmode)
          end
        when 97, 225
          if mode == :text
            thischar = textval('a', height, prevline, column)
          else
            thischar = graphval(33, graphicsmode)
          end
        when 98, 226
          if mode == :text
            thischar = textval('b', height, prevline, column)
          else
            thischar = graphval(34, graphicsmode)
          end
        when 99, 227
          if mode == :text
            thischar = textval('c', height, prevline, column)
          else
            thischar = graphval(35, graphicsmode)
          end
        when 100, 228
          if mode == :text
            thischar = textval('d', height, prevline, column)
          else
            thischar = graphval(36, graphicsmode)
          end
        when 101, 229
          if mode == :text
            thischar = textval('e', height, prevline, column)
          else
            thischar = graphval(37, graphicsmode)
          end
        when 102, 230
          if mode == :text
            thischar = textval('f', height, prevline, column)
          else
            thischar = graphval(38, graphicsmode)
          end
        when 103, 231
          if mode == :text
            thischar = textval('g', height, prevline, column)
          else
            thischar = graphval(39, graphicsmode)
          end
        when 104, 232
          if mode == :text
            thischar = textval('h', height, prevline, column)
          else
            thischar = graphval(40, graphicsmode)
          end
        when 105, 233
          if mode == :text
            thischar = textval('i', height, prevline, column)
          else
            thischar = graphval(41, graphicsmode)
          end
        when 106, 234
          if mode == :text
            thischar = textval('j', height, prevline, column)
          else
            thischar = graphval(42, graphicsmode)
          end
        when 107, 235
          if mode == :text
            thischar = textval('k', height, prevline, column)
          else
            thischar = graphval(43, graphicsmode)
          end
        when 108, 236
          if mode == :text
            thischar = textval('l', height, prevline, column)
          else
            thischar = graphval(44, graphicsmode)
          end
        when 109, 237
          if mode == :text
            thischar = textval('m', height, prevline, column)
          else
            thischar = graphval(45, graphicsmode)
          end
        when 110, 238
          if mode == :text
            thischar = textval('n', height, prevline, column)
          else
            thischar = graphval(46, graphicsmode)
          end
        when 111, 239
          if mode == :text
            thischar = textval('o', height, prevline, column)
          else
            thischar = graphval(47, graphicsmode)
          end
        when 112, 240
          if mode == :text
            thischar = textval('p', height, prevline, column)
          else
            thischar = graphval(48, graphicsmode)
          end
        when 113, 241
          if mode == :text
            thischar = textval('q', height, prevline, column)
          else
            thischar = graphval(49, graphicsmode)
          end
        when 114, 242
          if mode == :text
            thischar = textval('r', height, prevline, column)
          else
            thischar = graphval(50, graphicsmode)
          end
        when 115, 243
          if mode == :text
            thischar = textval('s', height, prevline, column)
          else
            thischar = graphval(51, graphicsmode)
          end
        when 116, 244
          if mode == :text
            thischar = textval('t', height, prevline, column)
          else
            thischar = graphval(52, graphicsmode)
          end
        when 117, 245
          if mode == :text
            thischar = textval('u', height, prevline, column)
          else
            thischar = graphval(53, graphicsmode)
          end
        when 118, 246
          if mode == :text
            thischar = textval('v', height, prevline, column)
          else
            thischar = graphval(54, graphicsmode)
          end
        when 119, 247
          if mode == :text
            thischar = textval('w', height, prevline, column)
          else
            thischar = graphval(55, graphicsmode)
          end
        when 120, 248
          if mode == :text
            thischar = textval('x', height, prevline, column)
          else
            thischar = graphval(56, graphicsmode)
          end
        when 121, 249
          if mode == :text
            thischar = textval('y', height, prevline, column)
          else
            thischar = graphval(57, graphicsmode)
          end
        when 122, 250
          if mode == :text
            thischar = textval('z', height, prevline, column)
          else
            thischar = graphval(58, graphicsmode)
          end
        when 123, 251
          if mode == :text
            thischar = textval('¼', height, prevline, column)
          else
            thischar = graphval(59, graphicsmode)
          end
        when 124, 252
          if mode == :text
            thischar = textval('|', height, prevline, column)
          else
            thischar = graphval(60, graphicsmode)
          end
        when 125, 253
          if mode == :text
            thischar = textval('¾', height, prevline, column)
          else
            thischar = graphval(61, graphicsmode)
          end
        when 126, 254
          if mode == :text
            thischar = textval('~', height, prevline, column)
          else
            thischar = graphval(62, graphicsmode)
          end
        when 127, 255
          thischar = graphval(63, graphicsmode)
        when 129
          if graphicshold == :hold && charline.last.ord > Offsets::GFX_CONTIG
            throw 'Check if held graphics would be valid here'
          end

          thischar = ' '
          mode = :text
          nextfore = Colour::RED
          concealed = :reveal
        when 130
          if graphicshold == :hold && charline.last.ord > Offsets::GFX_CONTIG
            throw 'Check if held graphics would be valid here'
          end

          thischar = ' '
          mode = :text
          nextfore = Colour::GREEN
          concealed = :reveal
        when 131
          if graphicshold == :hold && charline.last.ord > Offsets::GFX_CONTIG
            throw 'Check if held graphics would be valid here'
          end

          thischar = ' '
          mode = :text
          nextfore = Colour::YELLOW
          concealed = :reveal
        when 132
          if graphicshold == :hold && charline.last.ord > Offsets::GFX_CONTIG
            throw 'Check if held graphics would be valid here'
          end

          thischar = ' '
          mode = :text
          nextfore = Colour::BLUE
          concealed = :reveal
        when 133
          if graphicshold == :hold && charline.last.ord > Offsets::GFX_CONTIG
            throw 'Check if held graphics would be valid here'
          end

          thischar = ' '
          mode = :text
          nextfore = Colour::MAGENTA
          concealed = :reveal
        when 134
          if graphicshold == :hold && charline.last.ord > Offsets::GFX_CONTIG
            throw 'Check if held graphics would be valid here'
          end

          thischar = ' '
          mode = :text
          nextfore = Colour::CYAN
          concealed = :reveal
        when 135
          if graphicshold == :hold && charline.last.ord > Offsets::GFX_CONTIG
            throw 'Check if held graphics would be valid here'
          end

          thischar = ' '
          mode = :text
          nextfore = Colour::WHITE
          concealed = :reveal
        when 136
          if graphicshold == :hold && charline.last.ord > Offsets::GFX_CONTIG
            throw 'Check if held graphics would be valid here'
          end

          thischar = ' '
          flash = :flash
          stylechange = true
        when 137
          if graphicshold == :hold && charline.last.ord > Offsets::GFX_CONTIG
            throw 'Check if held graphics would be valid here'
          end

          thischar = ' '
          flash = :steady
          stylechange = true
        when 140
          if graphicshold == :hold && charline.last.ord > Offsets::GFX_CONTIG
            throw 'Check if held graphics would be valid here'
          end

          thischar = ' '
          height = :standard
        when 141
          if graphicshold == :hold && charline.last.ord > Offsets::GFX_CONTIG
            throw 'Check if held graphics would be valid here'
          end

          thischar = ' '
          height = :double
        when 145
          if graphicshold == :hold && charline.last.ord > Offsets::GFX_CONTIG
            thischar = charline.last
          else
            thischar = ' '
          end

          mode = :graphics
          nextfore = Colour::RED
          concealed = :reveal
        when 146
          if graphicshold == :hold && charline.last.ord > Offsets::GFX_CONTIG
            thischar = charline.last
          else
            thischar = ' '
          end

          mode = :graphics
          nextfore = Colour::GREEN
          concealed = :reveal
        when 147
          if graphicshold == :hold && charline.last.ord > Offsets::GFX_CONTIG
            thischar = charline.last
          else
            thischar = ' '
          end

          mode = :graphics
          nextfore = Colour::YELLOW
          concealed = :reveal
        when 148
          if graphicshold == :hold && charline.last.ord > Offsets::GFX_CONTIG
            thischar = charline.last
          else
            thischar = ' '
          end

          mode = :graphics
          nextfore = Colour::BLUE
          concealed = :reveal
        when 149
          if graphicshold == :hold && charline.last.ord > Offsets::GFX_CONTIG
            thischar = charline.last
          else
            thischar = ' '
          end

          mode = :graphics
          nextfore = Colour::MAGENTA
          concealed = :reveal
        when 150
          if graphicshold == :hold && charline.last.ord > Offsets::GFX_CONTIG
            thischar = charline.last
          else
            thischar = ' '
          end

          mode = :graphics
          nextfore = Colour::CYAN
          concealed = :reveal
        when 151
          if graphicshold == :hold && charline.last.ord > Offsets::GFX_CONTIG
            thischar = charline.last
          else
            thischar = ' '
          end

          mode = :graphics
          nextfore = Colour::WHITE
          concealed = :reveal
        when 152
          if graphicshold == :hold && charline.last.ord > Offsets::GFX_CONTIG
            throw 'Check if held graphics would be valid here'
          end

          thischar = ' '
          concealed = :conceal
        when 153
          if graphicshold == :hold && charline.last.ord > Offsets::GFX_CONTIG
            throw 'Check if held graphics would be valid here'
          end

          thischar = ' '
          graphicsmode = :contig
        when 154
          if graphicshold == :hold && charline.last.ord > Offsets::GFX_CONTIG
            throw 'Check if held graphics would be valid here'
          end

          thischar = ' '
          graphicsmode = :separa
        when 156
          if graphicshold == :hold && charline.last.ord > Offsets::GFX_CONTIG
            throw 'Check if held graphics would be valid here'
          end

          thischar = ' '
          backcolour = Colour::BLACK
          stylechange = true
        when 157
          if graphicshold == :hold && charline.last.ord > Offsets::GFX_CONTIG
            throw 'Check if held graphics would be valid here'
          end

          thischar = ' '
          backcolour = forecolour
          stylechange = true
        when 158
          if graphicshold == :hold && charline.last.ord > Offsets::GFX_CONTIG
            thischar = charline.last
          else
            thischar = ' '
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

        if concealed == :conceal && thischar != ' '
          throw 'Concealed graphics would have affected output at line ' + row.to_s + ' column ' + column.to_s
        end

        html = ''

        if stylechange
          if spanopen
            html << '</span>'
            spanopen = false
          end

          classes = []
          classes << 't' + forecolour.to_s if forecolour != Colour::WHITE
          classes << 'b' + backcolour.to_s if backcolour != Colour::BLACK
          classes << 'flash' if flash == :flash

          if classes.size > 0
            html << '<span class=' + (classes.size == 1 ? classes[0] : '"' + classes.join(' ') + '"') + '>'
            spanopen = true
          end
        end

        charline << thischar

        htmlline << html
        htmlline << thischar

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

          prevline = charline
          charline = []

          if spanopen
            htmlline << '</span>'
            spanopen = false
          end

          htmllines << htmlline.join('')
          htmlline = []
        end
      end

      htmllines.join("\n")
    end

    private def graphval(value, mode)
      if mode == :contig
        charval = Offsets::GFX_CONTIG + value
      else
        charval = Offsets::GFX_SEPARA + value
      end

      [charval].pack('U')
    end

    private def textval(char, height, prevline, column)
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

      unless prevline[column].nil?
        if prevline[column][0].ord.between?(Offsets::TXT_DBL_UPPER, Offsets::TXT_DBL_LOWER - 1)
          return [Offsets::TXT_DBL_LOWER + char.ord].pack('U')
        end
      end

      [Offsets::TXT_DBL_UPPER + char.ord].pack('U')
    end
  end

  Liquid::Template.register_filter(BBC::Mode7Filter)
end
