module Jekyll
  class IssuePage < Page
    def initialize(site, base, dir, issue)
      @site = site
      @base = base
      @dir = dir
      @name = 'index.html'
      
      self.process(@name)
      self.read_yaml(File.join(base, '_layouts'), 'issue.html')
      self.data['issue'] = issue
      self.data['title'] += issue['number']
    end
  end
  
  class IndexPage < Page
    def initialize(site, base, dir)
      @site = site
      @base = base
      @dir = dir
      @name = 'index.html'
      
      self.process(@name)
      self.read_yaml(File.join(base, '_layouts'), 'index.html')
      
      issues = []
      
      for discimg in Dir["discimgs/*"]
        issue = {}
        
        issue['imagepath'] = '/' + discimg
        issue['number'] = discimg[/\/(8BS[0-9-]+)\.dsd/,1]
        
        issues << issue
        
        site.pages << IssuePage.new(site, site.source, issue['number'], issue)
      end
      
      self.data['issues'] = issues.sort_by{ |i| i['number'] }
    end
  end
  
  class IndexPageGenerator < Generator
    safe true
    
    def generate(site)
      site.pages << IndexPage.new(site, site.source, '')
    end
  end
end
