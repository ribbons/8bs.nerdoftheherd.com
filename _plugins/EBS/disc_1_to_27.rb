# frozen_string_literal: true

# Copyright © 2015-2025 Matt Robinson
#
# SPDX-License-Identifier: GPL-3.0-or-later

require_relative 'disc'

module EBS
  class Disc1To27 < Disc
    require 'yaml'

    def initialize(site, issue, imagepath)
      super

      @date = @data[:date]

      @data[:menus].each do |menu|
        @menus << load_menu_data(menu)
      end

      @mapper.map(@menus, @disc.files)
    end

    private

    def load_menu_data(data)
      menu = Menu.new
      menu.title = data[:title]
      menu.id = data[:id]

      data[:entries]&.each do |entdat|
        entry = MenuEntry.new
        entry.title = entdat[:title]
        entry.type = entdat[:type]
        entry.model = entdat[:model]
        entry.modes = entdat[:modes]
        entry.captions = entdat[:captions]

        if entdat[:paths].nil?
          entry.id = entdat[:id]
        else
          entry.files = if entdat[:arcpaths].nil?
                          entdat[:paths].map { |path| [@disc.file(path)] }
                        else
                          entdat[:paths].zip(entdat[:arcpaths])
                                        .map do |path, arcpath|
                                          file = @disc.file(path)
                                          [file, file.parsed.file(arcpath)]
                                        end
                        end
        end

        menu.entries << entry
      end

      menu
    end
  end
end
