# frozen_string_literal: true

# Copyright © 2019-2025 Matt Robinson
#
# SPDX-License-Identifier: GPL-3.0-or-later

module EBS
  class ContentMapper
    def initialize(site, infodisc)
      @site = site
      @infodisc = infodisc

      @paths = {}
      @entries = Hash.new { |hash, key| hash[key] = [] }
      @arcimages = {}
    end

    def map(menus, discfiles)
      menus.each do |menu|
        menu.entries.reject { |e| e.type == :menu }.each do |entry|
          @entries[entry.files] << entry
        end
      end

      fileitems = discfiles.filter_map do |file|
        map_content(@infodisc, [[file]])
      end

      @entries.each do |files, entries|
        map_content(@infodisc, files) until entries.empty?
      end

      @site.pages << Output::FileListPage.new(
        @site, File.join(@infodisc.path, 'files'), @infodisc, fileitems
      )
    end

    private

    def map_content(parent, files)
      baselink = "#{@infodisc.path}content"

      files[0].each do |file|
        baselink += "/#{Jekyll::Utils.slugify(file.path)}"
      end

      linkpath = "#{baselink}/"
      suffix = 0

      while @paths[linkpath]
        suffix += 1
        linkpath = "#{baselink}-#{suffix}/"
      end

      entry = @entries[files].shift
      entry.linkpath = linkpath unless entry.nil?

      item = ContentItem.new(parent, linkpath, files, entry)
      return if item.type.nil?

      @paths[linkpath] = item
      extra = :default

      if item.type == :archive
        subfileitems = files[0][0].parsed.files.filter_map do |subfile|
          map_content(item, [[files[0][0], subfile]])
        end

        extra = subfileitems
      end

      @site.pages << Output::ContentPage.new(
        @site, linkpath, @infodisc, item, extra
      )

      if %i[basic run].include?(item.type)
        if files[0][0].type == :archive
          item.imagepath = map_arcimage(files, parent.path)
        end

        @site.static_files << Output::BootstrapBasicFile.new(
          @site, linkpath, item
        )
      end

      if item.type == :basic
        @site.pages << Output::ContentPage.new(
          @site, File.join(linkpath, 'list'), parent, item, :list
        )
      end

      item
    end

    def map_arcimage(files, linkpath)
      arcfiles = files.map { |f| f[0] }

      unless @arcimages.key?(arcfiles)
        @site.static_files << Output::DiscFile.new(
          @site, linkpath, files[0][0].path, arcfiles
        )

        @arcimages[arcfiles] = "#{linkpath}emulate.ssd"
      end

      @arcimages[arcfiles]
    end
  end
end
