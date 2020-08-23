# frozen_string_literal: true

# This file is part of the 8BS Online Conversion.
# Copyright © 2019-2020 by the authors - see the AUTHORS file for details.
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

module EBS
  module Output
    class BootstrapBasicFile < Jekyll::StaticFile
      def initialize(site, dir, item)
        super(site, site.source, dir, 'emulate.bas')
        @item = item
      end

      def write(dest)
        dest_path = destination(dest)

        FileUtils.mkdir_p(File.dirname(dest_path))
        FileUtils.rm(dest_path) if File.exist?(dest_path)
        File.write(dest_path, generate_basic)

        true
      end

      private

      def generate_basic
        basic = 'OSCLI("DRIVE ' + @item.files[0].side.to_s + "\")\n" \
                'OSCLI("DIR ' + @item.files[0].dir + "\")\n"

        if @item.type == :basic
          basic + 'CHAIN "' + @item.files[0].name + "\"\n"
        else
          basic + 'OSCLI("RUN ' + @item.files[0].name + "\")\n"
        end
      end
    end
  end
end
