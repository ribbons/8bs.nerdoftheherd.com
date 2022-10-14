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
  end
end
