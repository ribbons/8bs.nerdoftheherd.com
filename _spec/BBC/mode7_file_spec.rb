# frozen_string_literal: true

# Copyright © 2022 Matt Robinson
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

    it 'maps double height to upper or lower code points as appropriate' do
      parsed = described_class.parse(
        file_from_string(
          "\x0DABCDEFGHIJ\x0C                            " \
          "\x0DABCDEFGHIJKLMNOPQRST"
        )
      )

      expect(parsed.to_html).to eql(
        " #{[*0xE041..0xE04A].pack('U*')}                             \n " \
        "#{[*0xE141..0xE14A].pack('U*')}#{[*0xE04B..0xE054].pack('U*')}"
      )
    end

    it 'sets correct style for flashing text' do
      parsed = described_class.parse(
        file_from_string(
          "\x08FLASHING\x09STEADY" \
        )
      )

      expect(parsed.to_html).to eql(
        '<span class=flash> FLASHING</span> STEADY'
      )
    end

    it 'sets correct styles for text colours' do
      parsed = described_class.parse(
        file_from_string(
          "\x01RED                                    " \
          "\x02GREEN                                  " \
          "\x03YELLOW                                 " \
          "\x04BLUE                                   " \
          "\x05MAGENTA                                " \
          "\x06CYAN                                   " \
          "\x07WHITE                                  "
        )
      )

      expect(parsed.to_html).to eql(
        " <span class=t1>RED                                    </span>\n " \
        "<span class=t2>GREEN                                  </span>\n " \
        "<span class=t3>YELLOW                                 </span>\n " \
        "<span class=t4>BLUE                                   </span>\n " \
        "<span class=t5>MAGENTA                                </span>\n " \
        "<span class=t6>CYAN                                   </span>\n " \
        'WHITE                                  '
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
        " <span class=t1>                                      </span>\n " \
        "<span class=t2>                                      </span>\n " \
        "<span class=t3>                                      </span>\n " \
        "<span class=t4>                                      </span>\n " \
        "<span class=t5>                                      </span>\n " \
        "<span class=t6>                                      </span>\n " \
        '                                      '
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
        ' <span class="t1 b1">                   </span>' \
        "<span class=t1>                    </span>\n " \
        '<span class="t2 b2">                   </span>' \
        "<span class=t2>                    </span>\n " \
        '<span class="t3 b3">                   </span>' \
        "<span class=t3>                    </span>\n " \
        '<span class="t4 b4">                   </span>' \
        "<span class=t4>                    </span>\n " \
        '<span class="t5 b5">                   </span>' \
        "<span class=t5>                    </span>\n " \
        '<span class="t6 b6">                   </span>' \
        "<span class=t6>                    </span>\n " \
        '<span class=b7>                   </span>                    '
      )
    end
  end
end
