# frozen_string_literal: true

# Copyright © 2021-2025 Matt Robinson
#
# SPDX-License-Identifier: GPL-3.0-or-later

module Overcommit
  module Hook
    module PreCommit
      class Cppcheck < Base
        MESSAGE_REGEX = /^(?<file>.+):(?<line>\d+):/

        def run
          runcmd = command

          if @context.class.name != 'Overcommit::HookContext::RunAll'
            runcmd << '--suppress=unusedFunction'
          end

          result = execute(runcmd, args: applicable_files)

          extract_messages(
            result.stderr.chomp.split("\n"),
            MESSAGE_REGEX
          )
        end
      end
    end
  end
end
