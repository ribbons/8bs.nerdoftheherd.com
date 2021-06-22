# frozen_string_literal: true

# This file is part of the 8BS Online Conversion.
# Copyright © 2021 by the authors - see the AUTHORS file for details.
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

module Overcommit
  module Hook
    module PreCommit
      class Copyright < Base
        COPYRIGHT_REGEX = /Copyright © (?:[0-9]{4}-)?(?<year>[0-9]{4})/.freeze
        HASHBANG_REGEX = %r{^#! */(?:[a-z]+/)*[a-z0-9]+(?: |$)}.freeze
        NAMES_REGEX = /(?:^(?:CMakeLists[.]txt|Gemfile|Rakefile)|[.]
                          (?:bat|[ch]|cpp|cs|s?css|html|java|js|kt[ms]?|php|
                            p[lm]|rc|rb|sql|wxs))$/x.freeze

        def run
          messages = []
          outdated = @context.class.name != 'Overcommit::HookContext::RunAll'

          applicable_files.each do |filename|
            relfile = filename.delete_prefix("#{Overcommit::Utils.repo_root}/")

            File.open(filename, 'r') do |file|
              found = nil
              hashbang = false

              file.each_line do |line|
                if file.lineno == 1 && HASHBANG_REGEX.match(line)
                  hashbang = true
                end

                if (matches = COPYRIGHT_REGEX.match(line))
                  found = matches[:year].to_i
                  break
                end
              end

              if found
                if found != Time.now.year && outdated
                  messages << Overcommit::Hook::Message.new(
                    :error,
                    filename,
                    nil,
                    "#{relfile}: Copyright notice is out of date"
                  )
                end

                next
              end

              if hashbang || NAMES_REGEX.match(File.basename(filename))
                messages << Overcommit::Hook::Message.new(
                  :error,
                  filename,
                  nil,
                  "#{relfile}: Copyright notice is missing"
                )
              end
            rescue ArgumentError
              # Not encoded as UTF-8 or a binary file
              next
            end
          end

          messages
        end
      end
    end
  end
end
