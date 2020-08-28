# frozen_string_literal: true

# This file is part of the 8BS Online Conversion.
# Copyright © 2020 by the authors - see the AUTHORS file for details.
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

class GitHubFormatter < RuboCop::Formatter::BaseFormatter
  include RuboCop::PathUtil

  SEVERITY_MAPPING = {
    refactor:   'warning',
    convention: 'warning',
    warning:    'warning',
    error:      'error',
    fatal:      'error'
  }.freeze

  def file_finished(file, offenses)
    return if offenses.empty?

    offenses.each do |o|
      output.printf(
        "::%<type>s file=%<file>s,line=%<line>d,col=%<col>d::%<message>s\n",
        type: SEVERITY_MAPPING[o.severity.name],
        file: escape_path(file),
        line: o.line,
        col: o.real_column,
        message: o.message
      )
    end
  end

  def escape_message(data)
    return data.gsub('%',  '%25')
               .gsub("\r", '%0D')
               .gsub("\n", '%0A')
  end

  def escape_path(path)
    return smart_path(path).gsub('%', '%25')
                           .gsub(':', '%3A')
                           .gsub(',', '%2C')
                           .gsub("\r", '%0D')
                           .gsub("\n", '%0A')
  end
end
