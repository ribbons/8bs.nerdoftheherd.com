# This file is part of the 8BS Online Conversion.
# Copyright © 2007-2015 by the authors - see the AUTHORS file for details.
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
      GFX_STANDARD  = 0xE200
      GFX_DBL_UPPER = 0xE240
      GFX_DBL_LOWER = 0xE280
      GFX_SEPARATED = 0xC0
    end

    def mode7_to_html(input)
      row = 0
      column = 0
      spanopen = false
      lastchar = ''

      mode = :text
      flash = :steady
      forecolour = nextfore = Colour::WHITE
      backcolour = Colour::BLACK
      graphicsmode = :contig
      height = heighttype = :standard
      graphicshold = :release
      concealed = :reveal

      htmllines = []

      prevheights = Array.new(40) { :standard }
      htmlline = []

      input.each_byte do |c|
        if forecolour != nextfore
          forecolour = nextfore
          stylechange = true
        else
          stylechange = false
        end

        case c
        when 13
          while column < 39
            prevheights[column] = heighttype
            column += 1
          end
        when 0, 128, 138, 139, 142, 143, 144
          # 'Nothing' in the user guide - displays as a space
          thischar = ' '
        when 32, 160
          thischar = ' '
        when 33, 161
          if mode == :text
            thischar = textval('!', heighttype)
          else
            thischar = graphval(1, heighttype, graphicsmode)
          end
        when 34, 162
          if mode == :text
            thischar = textval('"', heighttype)
          else
            thischar = graphval(2, heighttype, graphicsmode)
          end
        when 35, 163
          if mode == :text
            thischar = '£'
          else
            thischar = graphval(3, heighttype, graphicsmode)
          end
        when 36, 164
          if mode == :text
            thischar = textval('$', heighttype)
          else
            thischar = graphval(4, heighttype, graphicsmode)
          end
        when 37, 165
          if mode == :text
            thischar = textval('%', heighttype)
          else
            thischar = graphval(5, heighttype, graphicsmode)
          end
        when 38, 166
          if mode == :text
            thischar = textval('&', heighttype)
          else
            thischar = graphval(6, heighttype, graphicsmode)
          end
        when 39, 167
          if mode == :text
            thischar = textval('\'', heighttype)
          else
            thischar = graphval(7, heighttype, graphicsmode)
          end
        when 40, 168
          if mode == :text
            thischar = textval('(', heighttype)
          else
            thischar = graphval(8, heighttype, graphicsmode)
          end
        when 41, 169
          if mode == :text
            thischar = textval(')', heighttype)
          else
            thischar = graphval(9, heighttype, graphicsmode)
          end
        when 42, 170
          if mode == :text
            thischar = textval('*', heighttype)
          else
            thischar = graphval(10, heighttype, graphicsmode)
          end
        when 43, 171
          if mode == :text
            thischar = textval('+', heighttype)
          else
            thischar = graphval(11, heighttype, graphicsmode)
          end
        when 44, 172
          if mode == :text
            thischar = textval(',', heighttype)
          else
            thischar = graphval(12, heighttype, graphicsmode)
          end
        when 45, 173
          if mode == :text
            thischar = textval('-', heighttype)
          else
            thischar = graphval(13, heighttype, graphicsmode)
          end
        when 46, 174
          if mode == :text
            thischar = textval('.', heighttype)
          else
            thischar = graphval(14, heighttype, graphicsmode)
          end
        when 47, 175
          if mode == :text
            thischar = textval('/', heighttype)
          else
            thischar = graphval(15, heighttype, graphicsmode)
          end
        when 48, 176
          if mode == :text
            thischar = textval('0', heighttype)
          else
            thischar = graphval(16, heighttype, graphicsmode)
          end
        when 49, 177
          if mode == :text
            thischar = textval('1', heighttype)
          else
            thischar = graphval(17, heighttype, graphicsmode)
          end
        when 50, 178
          if mode == :text
            thischar = textval('2', heighttype)
          else
            thischar = graphval(18, heighttype, graphicsmode)
          end
        when 51, 179
          if mode == :text
            thischar = textval('3', heighttype)
          else
            thischar = graphval(19, heighttype, graphicsmode)
          end
        when 52, 180
          if mode == :text
            thischar = textval('4', heighttype)
          else
            thischar = graphval(20, heighttype, graphicsmode)
          end
        when 53, 181
          if mode == :text
            thischar = textval('5', heighttype)
          else
            thischar = graphval(21, heighttype, graphicsmode)
          end
        when 54, 182
          if mode == :text
            thischar = textval('6', heighttype)
          else
            thischar = graphval(22, heighttype, graphicsmode)
          end
        when 55, 183
          if mode == :text
            thischar = textval('7', heighttype)
          else
            thischar = graphval(23, heighttype, graphicsmode)
          end
        when 56, 184
          if mode == :text
            thischar = textval('8', heighttype)
          else
            thischar = graphval(24, heighttype, graphicsmode)
          end
        when 57, 185
          if mode == :text
            thischar = textval('9', heighttype)
          else
            thischar = graphval(25, heighttype, graphicsmode)
          end
        when 58, 186
          if mode == :text
            thischar = textval(':', heighttype)
          else
            thischar = graphval(26, heighttype, graphicsmode)
          end
        when 59, 187
          if mode == :text
            thischar = textval(';', heighttype)
          else
            thischar = graphval(27, heighttype, graphicsmode)
          end
        when 60, 188
          if mode == :text
            thischar = textval('<', heighttype)
          else
            thischar = graphval(28, heighttype, graphicsmode)
          end
        when 61, 189
          if mode == :text
            thischar = textval('=', heighttype)
          else
            thischar = graphval(29, heighttype, graphicsmode)
          end
        when 62, 190
          if mode == :text
            thischar = textval('>', heighttype)
          else
            thischar = graphval(30, heighttype, graphicsmode)
          end
        when 63, 191
          if mode == :text
            thischar = textval('?', heighttype)
          else
            thischar = graphval(31, heighttype, graphicsmode)
          end
        when 64, 192
          thischar = textval('@', heighttype)
        when 65, 193
          thischar = textval('A', heighttype)
        when 66, 194
          thischar = textval('B', heighttype)
        when 67, 195
          thischar = textval('C', heighttype)
        when 68, 196
          thischar = textval('D', heighttype)
        when 69, 197
          thischar = textval('E', heighttype)
        when 70, 198
          thischar = textval('F', heighttype)
        when 71, 199
          thischar = textval('G', heighttype)
        when 72, 200
          thischar = textval('H', heighttype)
        when 73, 201
          thischar = textval('I', heighttype)
        when 74, 202
          thischar = textval('J', heighttype)
        when 75, 203
          thischar = textval('K', heighttype)
        when 76, 204
          thischar = textval('L', heighttype)
        when 77, 205
          thischar = textval('M', heighttype)
        when 78, 206
          thischar = textval('N', heighttype)
        when 79, 207
          thischar = textval('O', heighttype)
        when 80, 208
          thischar = textval('P', heighttype)
        when 81, 209
          thischar = textval('Q', heighttype)
        when 82, 210
          thischar = textval('R', heighttype)
        when 83, 211
          thischar = textval('S', heighttype)
        when 84, 212
          thischar = textval('T', heighttype)
        when 85, 213
          thischar = textval('U', heighttype)
        when 86, 214
          thischar = textval('V', heighttype)
        when 87, 215
          thischar = textval('W', heighttype)
        when 88, 216
          thischar = textval('X', heighttype)
        when 89, 217
          thischar = textval('Y', heighttype)
        when 90, 218
          thischar = textval('Z', heighttype)
        when 91, 219
          thischar = textval('[', heighttype)
        when 92, 220
          thischar = textval('½', heighttype)
        when 93, 221
          thischar = textval(']', heighttype)
        when 94, 222
          thischar = textval('^', heighttype)
        when 95, 223
          thischar = textval('#', heighttype)
        when 96, 224
          if mode == :text
            thischar = textval('`', heighttype)
          else
            thischar = graphval(32, heighttype, graphicsmode)
          end
        when 97, 225
          if mode == :text
            thischar = textval('a', heighttype)
          else
            thischar = graphval(33, heighttype, graphicsmode)
          end
        when 98, 226
          if mode == :text
            thischar = textval('b', heighttype)
          else
            thischar = graphval(34, heighttype, graphicsmode)
          end
        when 99, 227
          if mode == :text
            thischar = textval('c', heighttype)
          else
            thischar = graphval(35, heighttype, graphicsmode)
          end
        when 100, 228
          if mode == :text
            thischar = textval('d', heighttype)
          else
            thischar = graphval(36, heighttype, graphicsmode)
          end
        when 101, 229
          if mode == :text
            thischar = textval('e', heighttype)
          else
            thischar = graphval(37, heighttype, graphicsmode)
          end
        when 102, 230
          if mode == :text
            thischar = textval('f', heighttype)
          else
            thischar = graphval(38, heighttype, graphicsmode)
          end
        when 103, 231
          if mode == :text
            thischar = textval('g', heighttype)
          else
            thischar = graphval(39, heighttype, graphicsmode)
          end
        when 104, 232
          if mode == :text
            thischar = textval('h', heighttype)
          else
            thischar = graphval(40, heighttype, graphicsmode)
          end
        when 105, 233
          if mode == :text
            thischar = textval('i', heighttype)
          else
            thischar = graphval(41, heighttype, graphicsmode)
          end
        when 106, 234
          if mode == :text
            thischar = textval('j', heighttype)
          else
            thischar = graphval(42, heighttype, graphicsmode)
          end
        when 107, 235
          if mode == :text
            thischar = textval('k', heighttype)
          else
            thischar = graphval(43, heighttype, graphicsmode)
          end
        when 108, 236
          if mode == :text
            thischar = textval('l', heighttype)
          else
            thischar = graphval(44, heighttype, graphicsmode)
          end
        when 109, 237
          if mode == :text
            thischar = textval('m', heighttype)
          else
            thischar = graphval(45, heighttype, graphicsmode)
          end
        when 110, 238
          if mode == :text
            thischar = textval('n', heighttype)
          else
            thischar = graphval(46, heighttype, graphicsmode)
          end
        when 111, 239
          if mode == :text
            thischar = textval('o', heighttype)
          else
            thischar = graphval(47, heighttype, graphicsmode)
          end
        when 112, 240
          if mode == :text
            thischar = textval('p', heighttype)
          else
            thischar = graphval(48, heighttype, graphicsmode)
          end
        when 113, 241
          if mode == :text
            thischar = textval('q', heighttype)
          else
            thischar = graphval(49, heighttype, graphicsmode)
          end
        when 114, 242
          if mode == :text
            thischar = textval('r', heighttype)
          else
            thischar = graphval(50, heighttype, graphicsmode)
          end
        when 115, 243
          if mode == :text
            thischar = textval('s', heighttype)
          else
            thischar = graphval(51, heighttype, graphicsmode)
          end
        when 116, 244
          if mode == :text
            thischar = textval('t', heighttype)
          else
            thischar = graphval(52, heighttype, graphicsmode)
          end
        when 117, 245
          if mode == :text
            thischar = textval('u', heighttype)
          else
            thischar = graphval(53, heighttype, graphicsmode)
          end
        when 118, 246
          if mode == :text
            thischar = textval('v', heighttype)
          else
            thischar = graphval(54, heighttype, graphicsmode)
          end
        when 119, 247
          if mode == :text
            thischar = textval('w', heighttype)
          else
            thischar = graphval(55, heighttype, graphicsmode)
          end
        when 120, 248
          if mode == :text
            thischar = textval('x', heighttype)
          else
            thischar = graphval(56, heighttype, graphicsmode)
          end
        when 121, 249
          if mode == :text
            thischar = textval('y', heighttype)
          else
            thischar = graphval(57, heighttype, graphicsmode)
          end
        when 122, 250
          if mode == :text
            thischar = textval('z', heighttype)
          else
            thischar = graphval(58, heighttype, graphicsmode)
          end
        when 123, 251
          if mode == :text
            thischar = textval('¼', heighttype)
          else
            thischar = graphval(59, heighttype, graphicsmode)
          end
        when 124, 252
          if mode == :text
            thischar = textval('|', heighttype)
          else
            thischar = graphval(60, heighttype, graphicsmode)
          end
        when 125, 253
          if mode == :text
            thischar = textval('¾', heighttype)
          else
            thischar = graphval(61, heighttype, graphicsmode)
          end
        when 126, 254
          if mode == :text
            thischar = textval('~', heighttype)
          else
            thischar = graphval(62, heighttype, graphicsmode)
          end
        when 127, 255
          thischar = graphval(63, heighttype, graphicsmode)
        when 129
          if graphicshold == :hold && lastchar.ord > Offsets::GFX_STANDARD
            thischar = lastchar
          else
            thischar = ' '
          end

          mode = :text
          nextfore = Colour::RED
          concealed = :reveal
          graphicshold = :release
        when 130
          if graphicshold == :hold && lastchar.ord > Offsets::GFX_STANDARD
            thischar = lastchar
          else
            thischar = ' '
          end

          mode = :text
          nextfore = Colour::GREEN
          concealed = :reveal
          graphicshold = :release
        when 3, 131
          if graphicshold == :hold && lastchar.ord > Offsets::GFX_STANDARD
            thischar = lastchar
          else
            thischar = ' '
          end

          mode = :text
          nextfore = Colour::YELLOW
          concealed = :reveal
          graphicshold = :release
        when 132
          if graphicshold == :hold && lastchar.ord > Offsets::GFX_STANDARD
            thischar = lastchar
          else
            thischar = ' '
          end

          mode = :text
          nextfore = Colour::BLUE
          concealed = :reveal
          graphicshold = :release
        when 133
          if graphicshold == :hold && lastchar.ord > Offsets::GFX_STANDARD
            thischar = lastchar
          else
            thischar = ' '
          end

          mode = :text
          nextfore = Colour::MAGENTA
          concealed = :reveal
          graphicshold = :release
        when 134
          if graphicshold == :hold && lastchar.ord > Offsets::GFX_STANDARD
            thischar = lastchar
          else
            thischar = ' '
          end

          mode = :text
          nextfore = Colour::CYAN
          concealed = :reveal
          graphicshold = :release
        when 135
          if graphicshold == :hold && lastchar.ord > Offsets::GFX_STANDARD
            thischar = lastchar
          else
            thischar = ' '
          end

          mode = :text
          nextfore = Colour::WHITE
          concealed = :reveal
          graphicshold = :release
        when 136
          if graphicshold == :hold && lastchar.ord > Offsets::GFX_STANDARD
            thischar = lastchar
          else
            thischar = ' '
          end

          flash = :flash
          stylechange = true
        when 137
          if graphicshold == :hold && lastchar.ord > Offsets::GFX_STANDARD
            thischar = lastchar
          else
            thischar = ' '
          end

          flash = :steady
          stylechange = true
        when 140
          if graphicshold == :hold && lastchar.ord > Offsets::GFX_STANDARD
            throw 'Check if held graphics would be valid here'
          end

          thischar = ' '
          height = heighttype = :standard
        when 141
          if graphicshold == :hold && lastchar.ord > Offsets::GFX_STANDARD
            throw 'Check if held graphics would be valid here'
          end

          thischar = ' '
          height = :double

          if prevheights[column] == :dbl_upper
            heighttype = :dbl_lower
          else
            heighttype = :dbl_upper
          end
        when 145
          if graphicshold == :hold && lastchar.ord > Offsets::GFX_STANDARD
            thischar = lastchar
          else
            thischar = ' '
          end

          mode = :graphics
          nextfore = Colour::RED
          concealed = :reveal
        when 146
          if graphicshold == :hold && lastchar.ord > Offsets::GFX_STANDARD
            thischar = lastchar
          else
            thischar = ' '
          end

          mode = :graphics
          nextfore = Colour::GREEN
          concealed = :reveal
        when 147
          if graphicshold == :hold && lastchar.ord > Offsets::GFX_STANDARD
            thischar = lastchar
          else
            thischar = ' '
          end

          mode = :graphics
          nextfore = Colour::YELLOW
          concealed = :reveal
        when 148
          if graphicshold == :hold && lastchar.ord > Offsets::GFX_STANDARD
            thischar = lastchar
          else
            thischar = ' '
          end

          mode = :graphics
          nextfore = Colour::BLUE
          concealed = :reveal
        when 149
          if graphicshold == :hold && lastchar.ord > Offsets::GFX_STANDARD
            thischar = lastchar
          else
            thischar = ' '
          end

          mode = :graphics
          nextfore = Colour::MAGENTA
          concealed = :reveal
        when 150
          if graphicshold == :hold && lastchar.ord > Offsets::GFX_STANDARD
            thischar = lastchar
          else
            thischar = ' '
          end

          mode = :graphics
          nextfore = Colour::CYAN
          concealed = :reveal
        when 151
          if graphicshold == :hold && lastchar.ord > Offsets::GFX_STANDARD
            thischar = lastchar
          else
            thischar = ' '
          end

          mode = :graphics
          nextfore = Colour::WHITE
          concealed = :reveal
        when 152
          if graphicshold == :hold && lastchar.ord > Offsets::GFX_STANDARD
            throw 'Check if held graphics would be valid here'
          end

          thischar = ' '
          concealed = :conceal
        when 153
          if graphicshold == :hold && lastchar.ord > Offsets::GFX_STANDARD
            thischar = lastchar
          else
            thischar = ' '
          end

          graphicsmode = :contig
        when 154
          if graphicshold == :hold && lastchar.ord > Offsets::GFX_STANDARD
            thischar = lastchar
          else
            thischar = ' '
          end

          graphicsmode = :separa
        when 156
          if graphicshold == :hold && lastchar.ord > Offsets::GFX_STANDARD
            thischar = lastchar
          else
            thischar = ' '
          end

          backcolour = Colour::BLACK
          stylechange = true
        when 157
          if graphicshold == :hold && lastchar.ord > Offsets::GFX_STANDARD
            thischar = lastchar
          else
            thischar = ' '
          end

          backcolour = forecolour
          stylechange = true
        when 158
          if lastchar != '' && lastchar.ord > Offsets::GFX_STANDARD
            thischar = lastchar
          else
            thischar = ' '
          end

          graphicshold = :hold
        when 159
          if graphicshold == :hold && lastchar.ord > Offsets::GFX_STANDARD
            thischar = lastchar
          else
            thischar = ' '
          end

          graphicshold = :release
        else
          throw 'Unknown character value ' + c.to_s + ' at line ' + row.to_s + ' column ' + column.to_s
        end

        thischar = ' ' if concealed == :conceal

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

        prevheights[column] = heighttype

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
          height = heighttype = :standard
          graphicshold = :release
          concealed = :reveal

          lastchar = ''

          if spanopen
            htmlline << '</span>'
            spanopen = false
          end

          htmllines << htmlline.join('')
          htmlline = []
        else
          if height == :double
            if prevheights[column] == :dbl_upper
              heighttype = :dbl_lower
            else
              heighttype = :dbl_upper
            end
          end

          lastchar = thischar
        end
      end

      htmllines.join("\n")
    end

    private def graphval(value, heighttype, mode)
      case heighttype
      when :standard
        charval = Offsets::GFX_STANDARD + value
      when :dbl_upper
        charval = Offsets::GFX_DBL_UPPER + value
      else
        charval = Offsets::GFX_DBL_LOWER + value
      end

      charval += Offsets::GFX_SEPARATED if mode == :separa
      [charval].pack('U')
    end

    private def textval(char, heighttype)
      case heighttype
      when :standard
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
      when :dbl_lower
        return [Offsets::TXT_DBL_LOWER + char.ord].pack('U')
      else
        return [Offsets::TXT_DBL_UPPER + char.ord].pack('U')
      end
    end
  end

  Liquid::Template.register_filter(BBC::Mode7Filter)
end
