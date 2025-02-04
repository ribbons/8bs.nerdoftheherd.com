# frozen_string_literal: true

# Copyright © 2015-2025 Matt Robinson
#
# SPDX-License-Identifier: GPL-3.0-or-later

require 'rubocop/rake_task'
require 'rake/extensiontask'
require 'rake/clean'
require 'rspec/core/rake_task'
require 'html-proofer'
require 'jekyll'

RuboCop::RakeTask.new

desc 'Run JShint'
task :jshint do
  sh 'npm run --silent jshint'
end

desc 'Run all lint tasks'
task lint: %w[rubocop jshint cppcheck]

Rake::ExtensionTask.new do |ext|
  ext.name = 'bbc_native'
  ext.ext_dir = '_ext/BBC'
  ext.tmp_dir = File.join(Dir.tmpdir, '8bs_online_conversion')
  ext.lib_dir = File.join(__dir__, '/_plugins/BBC')
end

desc 'Build site and run HTMLProofer against the output'
task :proof do
  builddir = File.join(Dir.tmpdir, '8bs_online_conversion', 'html')

  ENV['JEKYLL_ENV'] = 'production'
  Jekyll::Commands::Build.process(destination: builddir)

  HTMLProofer.check_directory(
    builddir,
    checks: %w[Images Links Scripts Favicon],
    allow_hash_href: false,
    disable_external: true,
    ignore_urls: [
      %r{^/assets/convimages/},
      %r{^http://8bs[.]com/},
    ]
  ).run
end

desc 'Run Cppcheck'
task :cppcheck do
  puts 'Running Cppcheck...'

  cppcheck_conf = YAML.load_file(
    File.join(__dir__, '.overcommit.yml')
  )['PreCommit']['Cppcheck']

  included = Dir.glob(File.join(__dir__, '_ext', cppcheck_conf['include']))
  excluded = Dir.glob(File.join(__dir__, cppcheck_conf['exclude']))

  abort unless system 'cppcheck',
                      '--error-exitcode=2',
                      *cppcheck_conf['flags'],
                      *(included - excluded)

  puts 'No errors found'
end

RSpec::Core::RakeTask.new(rspec: :compile) do |rake|
  rake.pattern = '_spec/**/*_spec.rb'
end

CLEAN.include('_plugins/**/*.so')
CLEAN.include(File.join(Dir.tmpdir, '8bs_online_conversion'))
