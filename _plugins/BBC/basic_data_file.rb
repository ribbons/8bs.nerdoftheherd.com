# frozen_string_literal: true

# This file is part of the 8BS Online Conversion.
# Copyright © 2017-2021 by the authors - see the AUTHORS file for details.
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

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
