require 'bundler'
Bundler::GemHelper.install_tasks

require 'rake'
require 'rake/testtask'

Rake::TestTask.new do |t|
  t.libs << "test"
  t.verbose = true
  t.test_files = FileList['test/**/*_test.rb']
end
