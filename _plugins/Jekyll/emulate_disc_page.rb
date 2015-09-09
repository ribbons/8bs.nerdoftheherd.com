module Jekyll
  class EmulateDiscPage < Page
    def initialize(site, base, dir, disc)
      @site = site
      @base = base
      @dir = dir
      @name = 'index.html'

      process(@name)
      read_yaml(File.join(base, '_layouts'), 'emulate_disc.html')

      issue = disc.issue

      data['title'] += issue.number
      data['title'] += ' Disc ' + disc.number if issue.discs.count > 1

      data['disc'] = disc
    end
  end
end
