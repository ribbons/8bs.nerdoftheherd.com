# frozen_string_literal: true

# Copyright © 2017-2021 Matt Robinson
#
# SPDX-License-Identifier: GPL-3.0-or-later

module BBC
  class BasicDataFile
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

    def self.read_value(file)
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
      end
    end
  end
end
