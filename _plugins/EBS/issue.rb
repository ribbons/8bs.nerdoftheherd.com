module EBS
  class Issue < Liquid::Drop
    def initialize(number)
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

    def self.all_issues
      issues = {}

      Dir['discimgs/*'].each do |discimg|
        issuenum = discimg[%r{/8BS([0-9]+)(?:-[0-9])?\.dsd$}, 1]
        issues[issuenum] = Issue.new(issuenum) unless issues.key?(issuenum)

        disc = EBS::DiscReader.new(issues[issuenum], discimg)
        issues[issuenum].add_disc(disc)
      end

      issues.values.sort_by(&:number)
    end
  end
end
