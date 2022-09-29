# frozen_string_literal: true

# Copyright © 2017-2022 Matt Robinson
#
# SPDX-License-Identifier: GPL-3.0-or-later

module BBC
  module ReadBasicData
    private

    def read_value(file)
      return nil if file.empty?

      type = file.shift.ord

      case type
      when 0x00 # String
        return nil if file.empty?

        length = file.shift.ord
        return nil if file.length < length

        file.shift(length).reverse

      when 0x40 # Integer
        file.shift(4).unpack1('l>')

      when 0xFF # Real
        mantissa = file.shift(4).unpack1('L<')
        exponent = file.shift.unpack1('C')
        return nil if exponent.nil?
        return 0.0 if mantissa.zero? && exponent.zero?

        sign = (mantissa & 0x80000000).zero? ? 1 : -1
        Math.ldexp(0x80000000 | mantissa, exponent - 0xA0) * sign
      end
    end
  end

  class BasicDataFile
    extend ReadBasicData

    def self.parse(file)
      values = []

      until file.empty?
        value = read_value(file)
        return nil if value.nil?

        values.push value
      end

      BasicDataFile.new(values)
    end

    attr_reader :values

    def initialize(values)
      @values = values
    end
  end
end
