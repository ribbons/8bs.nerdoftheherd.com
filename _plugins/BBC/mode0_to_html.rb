require 'open3'

module BBCFilters
  def mode0_to_html(input)
    File.write('temp.txt', input)

    _stdin, stdout, stderr, wait_thr = Open3.popen3('php', 'convertmode0.php')
    output = stdout.gets(nil)
    stdout.close
    error = stderr.gets(nil)
    stderr.close

    if wait_thr.value != 0
      puts error
      throw 'convertmode0.php returned non-zero'
    end

    File.delete('temp.txt')

    output
  end
end

Liquid::Template.register_filter(BBCFilters)
