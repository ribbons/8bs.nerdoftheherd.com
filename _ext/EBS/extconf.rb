# This file is part of the 8BS Online Conversion.
# Copyright © 2017-2018 by the authors - see the AUTHORS file for details.
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

# rubocop:disable Style/GlobalVars
$CFLAGS << ' -DSYSV=1 -O3 -Wall -Wno-unused-function -Wno-unused-variable -Werror'
$CFLAGS = $CFLAGS.sub(/ -O2/, '')
# rubocop:enable Style/GlobalVars

create_makefile('arc2_c')
