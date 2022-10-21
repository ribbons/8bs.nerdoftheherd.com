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
  end
end
