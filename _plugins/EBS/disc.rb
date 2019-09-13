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

module EBS
  class Disc < Liquid::Drop
    def initialize(site, issue, image)
      @imagepath = '/' + image
      @issue = issue
      @path = image[%r{/(8BS[0-9-]+)\.[a-z]{3}$}, 1]
      @number = @path[/[0-9]-([0-9])/, 1] || '1'

      @menus = []
      @disc = BBC::DfsDisc.new(image)
      @mapper = ContentMapper.new(site, self)
    end

    attr_reader :imagepath, :issue, :path, :number, :date, :menus, :mapper,
                :disc

    private

    def model_from_title(title)
      if title =~ /(master )/i
        :master128
      else
        :modelb
      end
    end

    def apply_tweaks(imagepath)
      yamlpath = File.expand_path(
        '../../_data/' + File.basename(imagepath, '.*') + '.yaml', __dir__
      )
      return unless File.exist?(yamlpath)

      data = YAML.load_file(yamlpath)

      @menus.each do |menu|
        next unless data.key?(menu.id)

        menudata = data[menu.id]

        menu.entries.each do |entry|
          next unless menudata.key?(entry.title)

          itemdata = menudata[entry.title]

          if itemdata.key?(:paths)
            entry.files = itemdata[:paths].map { |path| @disc.file(path) }
          end

          entry.type = itemdata[:type] if itemdata.key?(:type)
          entry.offsets = itemdata[:offsets] if itemdata.key?(:offsets)
          entry.modes = itemdata[:modes] if itemdata.key?(:modes)
          entry.captions = itemdata[:captions] if itemdata.key?(:captions)
        end
      end
    end
  end
end
