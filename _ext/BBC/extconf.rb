# frozen_string_literal: true

# Copyright © 2015-2021 Matt Robinson
#
# SPDX-License-Identifier: GPL-3.0-or-later

require 'mkmf'

throw 'glib-2.0 is required' unless pkg_config('glib-2.0')
throw 'libpng is required' unless pkg_config('libpng')

throw 'libstdc++ is required' unless find_library('stdc++', 'main')
throw 'libbeebimage is required' unless find_library('beebimage', 'main')

# rubocop:disable Style/GlobalVars
$srcs = Dir.glob('**/*.c', base: $srcdir)
$CFLAGS = '-O3 -Wall -Werror -fPIC -std=c99'
$VPATH << '$(srcdir)/arc'
# rubocop:enable Style/GlobalVars

create_makefile('bbc_native')
