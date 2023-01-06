# frozen_string_literal: true

# Copyright © 2022-2023 Matt Robinson
# Copyright © 2020-2021 Chris Evans
# Copyright © 2020-2022 Tom Seddon
#
# SPDX-License-Identifier: GPL-3.0-or-later

require_relative '../../_plugins/BBC/bbc_native'
require_relative 'bbc_helpers'

RSpec.configure do |c|
  c.include BBCHelpers
end

module BBC
  describe Mode7File do
    it 'adds line breaks to screen data in correct locations' do
      parsed = described_class.parse(
        file_from_string(
          'LINE 1'.ljust(40) +
          'LINE 2'.ljust(40)
        )
      )

      expect(parsed.to_html).to eql(
        "LINE 1                                  \n" \
        'LINE 2                                  '
      )
    end

    it 'maps reserved and box characters to spaces' do
      parsed = described_class.parse(
        file_from_string(
          ".\x00.\x0A.\x0B.\x0E.\x0F.\x10.\x1B."
        )
      )

      expect(parsed.to_html).to eql(
        '. . . . . . . .'
      )
    end

    it 'maps alpha chars to correct code points/entities for Mode7 font' do
      parsed = described_class.parse(
        file_from_string(
          ' !"#$%&\'()*+,-./0123456789:;<=>?@       ' \
          'ABCDEFGHIJKLMNOPQRSTUVWXYZ[\\]^_`        ' \
          "abcdefghijklmnopqrstuvwxyz{|}~\x7F"
        )
      )

      expect(parsed.to_html).to eql(
        " !\"£$%&amp;'()*+,-./0123456789:;&lt;=&gt;?@       \n" \
        "ABCDEFGHIJKLMNOPQRSTUVWXYZ[½]^#`        \n" \
        'abcdefghijklmnopqrstuvwxyz¼|¾÷¶'
      )
    end

    it 'maps graphics chars to correct code points for Mode7 font' do
      parsed = described_class.parse(
        file_from_string(
          "\x17 !\"#$%&'()*+,-./0123456789:;<=>?       " \
          "\x17@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\\]^_       " \
          "\x17`abcdefghijklmnopqrstuvwxyz{|}~\x7F"
        )
      )

      expect(parsed.to_html).to eql(
        "  #{[*0xE201..0xE21F].pack('U*')}       \n " \
        "@ABCDEFGHIJKLMNOPQRSTUVWXYZ[½]^#       \n " \
        "#{[*0xE220..0xE23F].pack('U*')}"
      )
    end

    it 'maps separated graphics to correct code points for Mode7 font' do
      parsed = described_class.parse(
        file_from_string(
          "\x17\x1A !\"#$%&'()*+,-./0123456789:;<=>?      " \
          "\x17\x1A@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\\]^_      " \
          "\x17\x1A`abcdefghijklmnopqrstuvwxyz{|}~\x7F"
        )
      )

      expect(parsed.to_html).to eql(
        "   #{[*0xE2C1..0xE2DF].pack('U*')}      \n  " \
        "@ABCDEFGHIJKLMNOPQRSTUVWXYZ[½]^#      \n  " \
        "#{[*0xE2E0..0xE2FF].pack('U*')}"
      )
    end

    it 'maps double height to upper or lower code points per line' do
      parsed = described_class.parse(
        file_from_string(
          "    \x0DEFGHIJ\x0C                            " \
          "\x0DABCDEFGHIJKLMNOPQRST"
        )
      )

      expect(parsed.to_html).to eql(
        "     #{[*0xE045..0xE04A].pack('U*')}                             \n " \
        "#{[*0xE141..0xE154].pack('U*')}"
      )
    end

    it 'maps normal height chars to blank on line below double height upper' do
      parsed = described_class.parse(
        file_from_string(
          "                  \x0D                      " \
          'abcdefg                                 ' \
          'abcdefg'
        )
      )

      expect(parsed.to_html).to eql(
        '                                        ' \
        "\n                                        " \
        "\n abcdefg"
      )
    end

    it 'maps double-height contiguous graphics to correct code points' do
      parsed = described_class.parse(
        file_from_string(
          "\x17\x0D !\"#$%&'()*+,-./0123456789:;<=>?      " \
          "\x17\x0D !\"#$%&'()*+,-./0123456789:;<=>?      " \
          "\x17\x0D@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\\]^_      " \
          "\x17\x0D@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\\]^_      " \
          "\x17\x0D`abcdefghijklmnopqrstuvwxyz{|}~\x7F      " \
          "\x17\x0D`abcdefghijklmnopqrstuvwxyz{|}~\x7F"
        )
      )

      expect(parsed.to_html).to eql(
        "   #{[*0xE241..0xE25F].pack('U*')}      \n   " \
        "#{[*0xE281..0xE29F].pack('U*')}      \n  " \
        "#{[*0xE040..0xE05B].pack('U*')}      \n  " \
        "#{[*0xE140..0xE15B].pack('U*')}      \n  " \
        "#{[*0xE260..0xE27F].pack('U*')}      \n  " \
        "#{[*0xE2A0..0xE2BF].pack('U*')}" \
      )
    end

    it 'maps double-height separated graphics to correct code points' do
      parsed = described_class.parse(
        file_from_string(
          "\x17\x0D\x1A !\"#$%&'()*+,-./0123456789:;<=>?     " \
          "\x17\x0D\x1A !\"#$%&'()*+,-./0123456789:;<=>?     " \
          "\x17\x0D\x1A@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\\]^_     " \
          "\x17\x0D\x1A@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\\]^_     " \
          "\x17\x0D\x1A`abcdefghijklmnopqrstuvwxyz{|}~\x7F     " \
          "\x17\x0D\x1A`abcdefghijklmnopqrstuvwxyz{|}~\x7F"
        )
      )

      expect(parsed.to_html).to eql(
        "    #{[*0xE301..0xE31F].pack('U*')}     \n    " \
        "#{[*0xE341..0xE35F].pack('U*')}     \n   " \
        "#{[*0xE040..0xE05B].pack('U*')}     \n   " \
        "#{[*0xE140..0xE15B].pack('U*')}     \n   " \
        "#{[*0xE320..0xE33F].pack('U*')}     \n   " \
        "#{[*0xE360..0xE37F].pack('U*')}" \
      )
    end

    it 'sets and resets correct styles for flashing text' do
      parsed = described_class.parse(
        file_from_string(
          "\x08FLASHING\x09STEADY\x08FLASHING               " \
          'STEADY'
        )
      )

      expect(parsed.to_html).to eql(
        ' <span class=flash>FLASHING </span>STEADY ' \
        "<span class=flash>FLASHING               \n" \
        '</span>STEADY'
      )
    end

    it 'does not generate multiple spans for repeated flash codes' do
      parsed = described_class.parse(
        file_from_string(
          "\x08A\x08A\x08A"
        )
      )

      expect(parsed.to_html).to eql(
        ' <span class=flash>A A A'
      )
    end

    it 'does not generate spans for invisible flash style changes' do
      parsed = described_class.parse(
        file_from_string(
          "\x08A\x09\x08A\x09"
        )
      )

      expect(parsed.to_html).to eql(
        ' <span class=flash>A  A '
      )
    end

    it 'keeps spans open for flashing content on next line' do
      parsed = described_class.parse(
        file_from_string(
          "\x08A                                      " \
          "\x08A" \
        )
      )

      expect(parsed.to_html).to eql(
        " <span class=flash>A                                      \n " \
        'A'
      )
    end

    it 'sets and resets correct styles for text colours' do
      parsed = described_class.parse(
        file_from_string(
          "\x01RED                                     " \
          'WHITE                                  ' \
          "\x02GREEN                                   " \
          'WHITE                                  ' \
          "\x03YELLOW                                  " \
          'WHITE                                  ' \
          "\x04BLUE                                    " \
          'WHITE                                  ' \
          "\x05MAGENTA                                 " \
          'WHITE                                  ' \
          "\x06CYAN                                    " \
          'WHITE                                  ' \
          "\x07WHITE                                  "
        )
      )

      expect(parsed.to_html).to eql(
        " <span class=t1>RED                                    \n " \
        "</span>WHITE                                  \n " \
        "<span class=t2>GREEN                                  \n " \
        "</span>WHITE                                  \n " \
        "<span class=t3>YELLOW                                 \n " \
        "</span>WHITE                                  \n " \
        "<span class=t4>BLUE                                   \n " \
        "</span>WHITE                                  \n " \
        "<span class=t5>MAGENTA                                \n " \
        "</span>WHITE                                  \n " \
        "<span class=t6>CYAN                                   \n " \
        "</span>WHITE                                  \n " \
        'WHITE                                  '
      )
    end

    it 'does not generate multiple spans for repeated colour codes' do
      parsed = described_class.parse(
        file_from_string(
          "\x01A\x01A\x01A"
        )
      )

      expect(parsed.to_html).to eql(
        ' <span class=t1>A A A'
      )
    end

    it 'does not generate spans for invisible colour changes' do
      parsed = described_class.parse(
        file_from_string(
          "\x01\x02A\x03\x02A\x04"
        )
      )

      expect(parsed.to_html).to eql(
        '  <span class=t2>A  A '
      )
    end

    it 'keeps spans open for same colour on next line' do
      parsed = described_class.parse(
        file_from_string(
          "\x01A                                      " \
          "\x01A" \
        )
      )

      expect(parsed.to_html).to eql(
        " <span class=t1>A                                      \n " \
        'A'
      )
    end

    it 'sets correct styles for graphics colours' do
      parsed = described_class.parse(
        file_from_string(
          "\x11\x66                                      " \
          "\x12\x66                                      " \
          "\x13\x66                                      " \
          "\x14\x66                                      " \
          "\x15\x66                                      " \
          "\x16\x66                                      " \
          "\x17\x66                                      "
        )
      )

      expect(parsed.to_html).to eql(
        " <span class=t1>                                      \n " \
        "</span><span class=t2>                                      \n " \
        "</span><span class=t3>                                      \n " \
        "</span><span class=t4>                                      \n " \
        "</span><span class=t5>                                      \n " \
        "</span><span class=t6>                                      \n " \
        '</span>                                      '
      )
    end

    it 'sets correct styles for background colours' do
      parsed = described_class.parse(
        file_from_string(
          "\x11\x1D                  \x1C                   " \
          "\x12\x1D                  \x1C                   " \
          "\x13\x1D                  \x1C                   " \
          "\x14\x1D                  \x1C                   " \
          "\x15\x1D                  \x1C                   " \
          "\x16\x1D                  \x1C                   " \
          "\x17\x1D                  \x1C                   "
        )
      )

      expect(parsed.to_html).to eql(
        ' <span class="t1 b1">                   ' \
        "</span>                    \n " \
        '<span class="t2 b2">                   ' \
        "</span>                    \n " \
        '<span class="t3 b3">                   ' \
        "</span>                    \n " \
        '<span class="t4 b4">                   ' \
        "</span>                    \n " \
        '<span class="t5 b5">                   ' \
        "</span>                    \n " \
        '<span class="t6 b6">                   ' \
        "</span>                    \n " \
        '<span class=b7>                   </span>                    '
      )
    end

    it 'does not generate multiple spans for repeated new background codes' do
      parsed = described_class.parse(
        file_from_string(
          "\x1D\x1D\x1D"
        )
      )

      expect(parsed.to_html).to eql(
        '<span class=b7>   '
      )
    end

    it 'maps values with top bit set the same as without' do
      parsed = described_class.parse(
        file_from_string(
          "\x00\x80\x23\xA3\x5F\xDF\x7F\xFF"
        )
      )

      expect(parsed.to_html).to eql(
        '  ££##¶¶'
      )
    end

    it 'resets graphics, height, separated and hold at end of line' do
      parsed = described_class.parse(
        file_from_string(
          "\x11\x1D\x1A\x0D\x1Ea#{' ' * 74}" \
          "should have reset\x17a"
        )
      )

      expect(parsed.to_html).to eql(
        ' <span class="t1 b1">                                      ' \
        "\n</span>                                        \n" \
        'should have reset '
      )
    end

    it 'correctly stores space as a held character' do
      parsed = described_class.parse(
        file_from_string(
          "\x17\x1E\x7F \x1F"
        )
      )

      expect(parsed.to_html).to eql(
        '    '
      )
    end

    it 'clears held character when hold is disabled' do
      parsed = described_class.parse(
        file_from_string(
          "\x17\x1E\x7F\x1F \x1E\x1F"
        )
      )

      expect(parsed.to_html).to eql(
        '     '
      )
    end

    it 'uses held graphics for reserved and box characters' do
      parsed = described_class.parse(
        file_from_string(
          "\x17\x1E\x7F\x00\x0A\x0B\x0E\x0F\x10\x1B"
        )
      )

      expect(parsed.to_html).to eql(
        '  '
      )
    end

    it 'does not hold blast through text before hold' do
      parsed = described_class.parse(
        file_from_string(
          "\x17A\x1E"
        )
      )

      expect(parsed.to_html).to eql(
        ' A '
      )
    end

    it 'does not hold characters when in text mode' do
      parsed = described_class.parse(
        file_from_string(
          "\x1Ea\x1F"
        )
      )

      expect(parsed.to_html).to eql(
        ' a '
      )
    end

    it 'resets control characters to space at EOL' do
      parsed = described_class.parse(
        file_from_string(
          "                                     \x17\x1E\x7F" \
          "\x17"
        )
      )

      expect(parsed.to_html).to eql(
        "                                       \n "
      )
    end

    it 'handles teletest: FOREGROUND COLOR IS SET-AFTER' do
      parsed = described_class.parse(
        file_from_string(
          "\x92\x9E\xFF\x93\x94"
        )
      )

      expect(parsed.to_html).to eql(
        '  <span class=t2></span><span class=t3>'
      )
    end

    it 'handles teletest: BG->FG IS SET-AT' do
      parsed = described_class.parse(
        file_from_string(
          "\x94\x9D\x95\x9E\xFF\x98"
        )
      )

      expect(parsed.to_html).to eql(
        ' <span class="t4 b4">   </span><span class="t5 b4"> '
      )
    end

    it 'handles teletest: ASCII DOES NOT AFFECT HELD CHARACTER' do
      parsed = described_class.parse(
        file_from_string(
          "\x97\x9E\xFFA\x97"
        )
      )

      expect(parsed.to_html).to eql(
        '  A'
      )
    end

    it 'handles teletest: HOLD ON SET-AT, HOLD OFF SET-AFTER' do
      parsed = described_class.parse(
        file_from_string(
          "\x97\xFF\x9E\x9F\x9F"
        )
      )

      expect(parsed.to_html).to eql(
        '  '
      )
    end

    it 'handles teletest: CLEAR HELD CHARACTER #1' do
      parsed = described_class.parse(
        file_from_string(
          "\x97\xFF\x9E\x87\x87"
        )
      )

      expect(parsed.to_html).to eql(
        '  '
      )
    end

    it 'handles teletest: CLEAR HELD CHARACTER #2' do
      parsed = described_class.parse(
        file_from_string(
          "\x97\xFF\x97\x9E"
        )
      )

      expect(parsed.to_html).to eql(
        '   '
      )
    end

    it 'handles teletest: CLEAR HELD CHARACTER #3' do
      parsed = described_class.parse(
        file_from_string(
          "\x8D\x97\xFF\x9E\x8D\x8C\x97\xFF\x9E\x8C\x8D"
        )
      )

      expect(parsed.to_html).to eql(
        '     '
      )
    end

    it 'handles teletest: MISSING SECOND DOUBLE' do
      parsed = described_class.parse(
        file_from_string(
          "\x97\x9A\x8D\xFF                                    " \
          "\x97\x9A\x8C\xFF"
        )
      )

      expect(parsed.to_html).to eql(
        "                                       \n    "
      )
    end

    it 'handles teletest: GRAPHICS SEPARATED/CONTIGUOUS STATE' do
      parsed = described_class.parse(
        file_from_string(
          "\x97\xFF\x87\xFF\x99\xFF\x9A\xFF\x97\xFF\x87\xFF\x97\xFF"
        )
      )

      expect(parsed.to_html).to eql(
        '  ¶ ¶ ¶  ¶ '
      )
    end
  end
end
