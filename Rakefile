# This file is part of the 8BS Online Conversion.
# Copyright © 2015-2016 by the authors - see the AUTHORS file for details.
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
require 'jshintrb/jshinttask'
require 'rake/extensiontask'
require 'rake/clean'

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

Rake::ExtensionTask.new do |ext|
  ext.name = 'native_filters_c'
  ext.ext_dir = '_ext/BBC'
  ext.tmp_dir = File.join(Dir.tmpdir, '8bs_online_conversion')
  ext.lib_dir = '_plugins/BBC'
end

CLEAN.include('_plugins/**/*.so')
CLEAN.include(File.join(Dir.tmpdir, '8bs_online_conversion'))
