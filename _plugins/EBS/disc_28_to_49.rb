# frozen_string_literal: true

# Copyright © 2015-2021 Matt Robinson
#
# SPDX-License-Identifier: GPL-3.0-or-later

require_relative 'disc'

module EBS
  class Disc28To49 < Disc
    def initialize(site, issue, imagepath)
      super(site, issue, imagepath)

      bootlines = disc.file('$.!Boot').content.split("\r")
      datevals = bootlines[6]
                 .match(/(?:([0-9]+)[A-Z]{2} )?([A-Z]{3})[A-Z]* ([0-9]{4})/i)
                 .captures

      @date = datevals[1..2].join('/')
      @date = "#{datevals[0].rjust(2, '0')}/#{@date}" unless datevals[0].nil?

      basic = disc.file('$.Menu').parsed
      id_mapping = read_id_map(basic)
      convert_menu_data(basic.data, id_mapping)
      apply_tweaks

      @mapper.map(@menus, @disc.files)
    end

    private

    # The first version of the menu by S.Flintham includes 'PROCla' which takes
    # a menu number and then RESTOREs to the relevant data line.
    # Read these values and build a reverse lookup hash to convert line numbers
    # into menu numbers.
    def read_id_map(basic)
      map = {}
      inproc = false

      basic.lines.each_value do |line|
        if inproc
          break if line.match(/^ENDPROC$/)

          extract = line.match(/^IFf%=([0-9])THENRESTORE(?: ?([0-9]+))?$/)
          raise "Unexpected line in PROCla: \"#{line}\"" unless extract

          menuid = extract.captures[0].to_i

          linenum = if extract.captures[1].nil?
                      basic.data.keys.first
                    else
                      extract.captures[1].to_i
                    end

          map[linenum] = menuid unless map.key?(linenum)
        elsif line.match(/^DEFPROCla\(f%\)$/)
          inproc = true
        end
      end

      raise 'Unable to find PROCla' unless inproc

      map
    end

    def convert_menu_data(lines, id_mapping)
      entries = 0
      menu = nil
      first_files = nil

      lines.each do |linenum, vals|
        if entries.zero?
          menuid = id_mapping[linenum]

          unless menu.nil?
            @menus << menu

            # Remove second+ files which are the first file on another entry
            menu.entries.each do |entry|
              next if entry.files.nil? || entry.files.size == 1

              entry.files.delete_if.with_index do |file, i|
                i.positive? && first_files.include?(file)
              end
            end
          end

          menu = Menu.new
          menu.title = vals[0]
          menu.id = menuid

          entries = vals[1].to_i
          first_files = []
        else
          entry = MenuEntry.new
          entry.title = vals[0]
          entry.model = model_from_title(entry.title)

          unless vals[3] == ''
            entry.files = vals[3].split('@').each.map do |file|
              [@disc.file("#{vals[2]}.#{file}")]
            end

            first_files << entry.files.first
          end

          command = vals[1]
          is_text = vals[4].to_i == -1
          is_mode7 = vals[5].to_i == -1
          menuid = vals[6].to_i

          if menuid != 0
            entry.type = :menu
            entry.id = menuid
          elsif is_text && !is_mode7
            entry.type = :mode0
          elsif is_text && is_mode7
            entry.type = :mode7
          else
            case command.upcase
            when '*RUN'
              entry.type = :run
            when 'CHAIN'
              entry.type = :basic
            when '*EX.'
              entry.type = :exec
            else
              throw "Unknown command '#{command}' for '#{entry.title}'"
            end
          end

          menu.entries << entry
          entries -= 1
        end
      end

      @menus << menu
    end
  end
end
