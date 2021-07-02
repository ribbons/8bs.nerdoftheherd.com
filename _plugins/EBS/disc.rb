# frozen_string_literal: true

# Copyright © 2015-2021 Matt Robinson
#
# SPDX-License-Identifier: GPL-3.0-or-later

module EBS
  class Disc < Liquid::Drop
    def initialize(site, issue, image)
      super()

      @imagepath = "/#{image}"
      @issue = issue
      @path = "/#{image[%r{/(8BS[0-9-]+)\.[a-z]{3}$}, 1]}/"
      @number = @path[/[0-9]-([0-9])/, 1] || '1'

      yamlpath = File.expand_path(
        "../../_data/#{File.basename(image, '.*')}.yaml", __dir__
      )

      @data = YAML.load_file(yamlpath) if File.exist?(yamlpath)

      @menus = []
      @disc = BBC::DfsDisc.new(image, @data&.fetch(:tweaks, nil))
      @mapper = ContentMapper.new(site, self)
    end

    attr_reader :imagepath, :issue, :path, :number, :date, :menus, :mapper,
                :disc

    def navchain
      [self]
    end

    def navtitle
      title = "8BS#{issue.number}"
      title += " Disc #{number}" if issue.discs.size > 1
      title
    end

    private

    def model_from_title(title)
      if title =~ /(master )/i
        :master128
      else
        :modelb
      end
    end

    def apply_tweaks
      return if @data.nil?

      @menus.each do |menu|
        next unless @data.key?(menu.id)

        menudata = @data[menu.id]

        menu.entries.each do |entry|
          next unless menudata.key?(entry.title)

          itemdata = menudata[entry.title]

          if itemdata.key?(:paths)
            entry.files = itemdata[:paths].map { |path| [@disc.file(path)] }
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
