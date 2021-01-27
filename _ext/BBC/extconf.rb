# frozen_string_literal: true

# This file is part of the 8BS Online Conversion.
# Copyright © 2015-2021 by the authors - see the AUTHORS file for details.
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

require 'mkmf'

throw 'glib-2.0 is required' unless pkg_config('glib-2.0')
throw 'libpng is required' unless pkg_config('libpng')

throw 'libstdc++ is required' unless find_library('stdc++', 'main')
throw 'libbeebimage is required' unless find_library('beebimage', 'main')

# rubocop:disable Style/GlobalVars
$srcs = Dir.glob('**/*.c', base: $srcdir)
$CFLAGS = '-O3 -Wall -Werror -fPIC'
$VPATH << '$(srcdir)/arc'
# rubocop:enable Style/GlobalVars

create_makefile('bbc_native')
