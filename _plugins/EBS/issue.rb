# frozen_string_literal: true

# Copyright © 2015-2024 Matt Robinson
#
# SPDX-License-Identifier: GPL-3.0-or-later

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
        when 50..67
          disc = EBS::Disc50To67.new(site, issues[issuenum], discimg)
        end

        issues[issuenum].add_disc(disc)
      end

      issues.values.sort_by(&:number)
    end
  end
end
