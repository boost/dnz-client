require 'rubygems'
gem 'hoe', '>= 2.1.0'
require 'hoe'
require 'fileutils'
require './lib/dnz'

Hoe.plugin :newgem

# Generate all the Rake tasks
# Run 'rake -T' to see list of generated tasks (from gem root directory)
$hoe = Hoe.spec 'dnz-client' do
  self.developer 'Jeremy Wells', 'jeremy@boost.co.nz'
  self.post_install_message = 'PostInstall.txt' # TODO remove if post-install message not required
  self.description = "Ruby library for accessing Digital New Zealand's search API (digitalnz.org)"
  #self.rubyforge_name       = self.name # TODO this is default value
  self.extra_deps         = [['activesupport','>= 2.0.2'], ['nokogiri', '>= 1.2.3']]
  self.extra_rdoc_files   << 'README.rdoc'
end

require 'newgem/tasks'
Dir['tasks/**/*.rake'].each { |t| load t }

# TODO - want other tests/tasks run by default? Add them to the list
# remove_task :default
# task :default => [:spec, :features]
