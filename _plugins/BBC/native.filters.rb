# frozen_string_literal: true

# Copyright © 2015-2019 Matt Robinson
#
# SPDX-License-Identifier: GPL-3.0-or-later

require_relative 'bbc_native'

module BBC
  Liquid::Template.register_filter(BBC::NativeFilters)
end
