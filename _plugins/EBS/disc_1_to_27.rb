# frozen_string_literal: true

# This file is part of the 8BS Online Conversion.
# Copyright © 2015-2019 by the authors - see the AUTHORS file for details.
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

require_relative 'disc'

module EBS
  class Disc1To27 < Disc
    require 'yaml'

    def initialize(site, issue, imagepath)
      super(site, issue, imagepath)

      id = File.basename(imagepath, '.*')

      data = YAML.load_file(
        File.expand_path('../../_data/' + id + '.yaml', __dir__)
      )

      @date = data[:date]

      data[:menus].each do |menu|
        @menus << load_menu_data(menu)
      end

      @mapper.map_menus(@menus)
    end

    private

    def load_menu_data(data)
      menu = Menu.new
      menu.title = data[:title]
      menu.id = data[:id]

      data[:entries]&.each do |entdat|
        entry = MenuEntry.new(self)
        entry.title = entdat[:title]
        entry.type = entdat[:type]
        entry.model = entdat[:model]
        entry.offsets = entdat[:offsets]
        entry.modes = entdat[:modes]
        entry.captions = entdat[:captions]
        entry.arcpaths = entdat[:arcpaths]
        entry.arcfix = entdat[:arcfix]

        if entdat[:paths].nil?
          entry.id = entdat[:id]
        else
          entry.files = entdat[:paths].map { |path| @disc.file(path) }
        end

        menu.entries << entry
      end

      menu
    end
  end
end
