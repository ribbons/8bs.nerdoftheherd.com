require 'rubocop/rake_task'
require 'jshintrb/jshinttask'

RuboCop::RakeTask.new

Jshintrb::JshintTask.new :jshint do |t|
  t.pattern = 'common/script/*.js'

  t.options = {
    bitwise: true,
    curly: true,
    eqeqeq: true,
    forin: true,
    latedef: true,
    noarg: true,
    nonew: true,
    singleGroups: true,
    strict: true,
    undef: true,

    browser: true,
    jquery: true
  }
end

task lint: %w(rubocop jshint)
