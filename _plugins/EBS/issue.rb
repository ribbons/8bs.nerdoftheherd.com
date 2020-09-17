# frozen_string_literal: true

# This file is part of the 8BS Online Conversion.
# Copyright © 2015-2020 by the authors - see the AUTHORS file for details.
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
  class Issue < Liquid::Drop
    def initialize(number)
      super()
      @number = number
      @discs = []
    end

    def add_disc(disc)
      @discs << disc
      @discs.sort_by!(&:number)
    end

    def date
      @discs[0].date
    end

    attr_reader :number, :discs

    def self.all_issues(site)
      issues = {}

      Dir['discimgs/*'].each do |discimg|
        issuenum = discimg[%r{/8BS([0-9]+)(?:-[0-9])?\.[a-z]{3}$}, 1].to_i
        issues[issuenum] = Issue.new(issuenum) unless issues.key?(issuenum)

        case issuenum
        when 1..27
          disc = EBS::Disc1To27.new(site, issues[issuenum], discimg)
        when 28..49
          disc = EBS::Disc28To49.new(site, issues[issuenum], discimg)
        when 50..66
          disc = EBS::Disc50To66.new(site, issues[issuenum], discimg)
        end

        issues[issuenum].add_disc(disc)
      end

      issues.values.sort_by(&:number)
    end
  end
end
