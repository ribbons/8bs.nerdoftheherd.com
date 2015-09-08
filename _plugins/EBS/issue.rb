module EBS
  class Issue < Liquid::Drop
    def initialize(number, date)
      @number = number
      @date = date
      @discs = []
    end

    def add_disc(disc)
      @discs << disc
      discs.sort_by!(&:number)
    end

    attr_reader :number, :date, :discs

    def self.all_issues
      issues = {}

      Dir['discimgs/*'].each do |discimg|
        menu = EBS::MenuGroup.new(discimg)

        unless issues.key?(menu.issuenum)
          issues[menu.issuenum] = Issue.new(menu.issuenum, menu.date)
        end

        disc = Disc.new(discimg, issues[menu.issuenum], menu)
        issues[menu.issuenum].add_disc(disc)
      end

      issues.values.sort_by(&:number)
    end
  end
end
