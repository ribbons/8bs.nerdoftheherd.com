module EBS
  class Issue < Liquid::Drop
    def initialize(number, date)
      @number = number
      @date = date
      @discs = []
    end

    def add_disc(disc)
      disc.issue = self
      @discs << disc
      discs.sort_by!(&:number)
    end

    attr_reader :number, :date, :discs

    def self.all_issues
      issues = {}

      Dir['discimgs/*'].each do |discimg|
        menu = EBS::MenuGroup.new(discimg)

        disc = Disc.new(discimg, menu)

        if issues.key?(menu.issuenum)
          issues[menu.issuenum].add_disc(disc)
        else
          issue = Issue.new(menu.issuenum, menu.date)
          issue.add_disc(disc)
          issues[issue.number] = issue
        end
      end

      issues.values.sort_by(&:number)
    end
  end
end
