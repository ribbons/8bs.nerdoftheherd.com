module Jekyll
  class IndexPage < Page
    def initialize(site, issues)
      @site = site
      @base = site.source
      @dir = ''
      @name = 'index.html'

      process(@name)
      read_yaml(File.join(@base, '_layouts'), 'index.html')

      data['issues'] = issues
    end
  end
end
