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
      class FileEncoding < Base
        def run
          messages = []

          applicable_files.each do |file|
            content = File.read(file)

            # Definitely not a text file if it contains null bytes
            next if content.b.include?("\x00")

            relfile = file.delete_prefix("#{Overcommit::Utils.repo_root}/")

            if !content.valid_encoding?
              messages << Overcommit::Hook::Message.new(
                :error,
                file,
                nil,
                "#{relfile}: Not encoded as UTF-8"
              )
            elsif content.start_with?("\uFEFF")
              messages << Overcommit::Hook::Message.new(
                :error,
                file,
                nil,
                "#{relfile}: Starts with a UTF-8 BoM"
              )
            end
          end

          messages
        end
      end
    end
  end
end
