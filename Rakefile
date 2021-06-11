# frozen_string_literal: true

# This file is part of the 8BS Online Conversion.
# Copyright © 2015-2021 by the authors - see the AUTHORS file for details.
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

require 'rubocop/rake_task'
require 'rake/extensiontask'
require 'rake/clean'
require 'rspec/core/rake_task'
require 'html-proofer'
require 'jekyll'

RuboCop::RakeTask.new

task :jshint do
  sh 'npm run --silent jshint'
end

task lint: %w[rubocop jshint cppcheck]

Rake::ExtensionTask.new do |ext|
  ext.name = 'bbc_native'
  ext.ext_dir = '_ext/BBC'
  ext.tmp_dir = File.join(Dir.tmpdir, '8bs_online_conversion')
  ext.lib_dir = '_plugins/BBC'
end

task :proof do
  builddir = File.join(Dir.tmpdir, '8bs_online_conversion', 'html')

  ENV['JEKYLL_ENV'] = 'production'
  Jekyll::Commands::Build.process(destination: builddir)

  HTMLProofer.check_directory(
    builddir,
    check_html: true,
    check_favicon: true,
    disable_external: true,
    alt_ignore: [%r{^/assets/convimages/}]
  ).run
end

task :cppcheck do
  puts 'Running Cppcheck...'

  sh 'cppcheck --quiet --error-exitcode=2 --enable=all --std=c99 \
               --suppress=missingIncludeSystem --inline-suppr _ext/BBC/*.c',
     verbose: false

  puts 'No errors found'
end

RSpec::Core::RakeTask.new(rspec: :compile) do |rake|
  rake.pattern = '_spec/**/*_spec.rb'
end

CLEAN.include('_plugins/**/*.so')
CLEAN.include(File.join(Dir.tmpdir, '8bs_online_conversion'))
