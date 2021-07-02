# frozen_string_literal: true

# Copyright © 2016 Matt Robinson
#
# SPDX-License-Identifier: GPL-3.0-or-later

module Jekyll
  module ChompDotFilter
    def chomp_dot(input)
      input.chomp('.')
    end
  end

  Liquid::Template.register_filter(Jekyll::ChompDotFilter)
end
