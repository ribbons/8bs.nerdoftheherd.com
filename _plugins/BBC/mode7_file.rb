# frozen_string_literal: true

# Copyright © 2022 Matt Robinson
#
# SPDX-License-Identifier: GPL-3.0-or-later

module BBC
  class Mode7File
    def initialize(screendata)
      @screendata = screendata
    end

    attr_accessor :screendata
  end
end
