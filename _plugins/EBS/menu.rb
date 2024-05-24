# frozen_string_literal: true

# Copyright © 2015-2024 Matt Robinson
#
# SPDX-License-Identifier: GPL-3.0-or-later

module EBS
  class Menu < Liquid::Drop
    def initialize
      super
      @entries = []
    end

    attr_accessor :title, :id, :entries
  end
end
