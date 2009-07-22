# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{dnz-client}
  s.version = "0.0.2"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Jeremy Wells"]
  s.date = %q{2009-07-22}
  s.description = %q{Ruby library for accessing Digital New Zealand's search API (digitalnz.org)}
  s.email = ["jeremy@boost.co.nz"]
  s.extra_rdoc_files = ["History.txt", "Manifest.txt", "PostInstall.txt", "License.txt"]
  s.files = ["History.txt", "Manifest.txt", "PostInstall.txt", "README.rdoc", "License.txt", "Rakefile", "lib/dnz.rb", "lib/dnz/attributes.rb", "lib/dnz/client.rb", "lib/dnz/facet.rb", "lib/dnz/result.rb", "lib/dnz/search.rb", "script/console", "script/destroy", "script/generate", "spec/dnz/client_spec.rb", "spec/dnz/result_spec.rb", "spec/dnz/search_spec.rb", "spec/spec.opts", "spec/spec_helper.rb", "tasks/rspec.rake"]
  s.homepage = %q{http://github.com/boost/dnz-client}
  s.post_install_message = %q{PostInstall.txt}
  s.rdoc_options = ["--main", "README.rdoc"]
  s.require_paths = ["lib"]
  s.rubyforge_project = %q{dnz-client}
  s.rubygems_version = %q{1.3.3}
  s.summary = %q{}

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<activesupport>, [">= 2.0.2"])
      s.add_runtime_dependency(%q<nokogiri>, [">= 1.2.3"])
      s.add_development_dependency(%q<hoe>, [">= 2.3.2"])
    else
      s.add_dependency(%q<activesupport>, [">= 2.0.2"])
      s.add_dependency(%q<nokogiri>, [">= 1.2.3"])
      s.add_dependency(%q<hoe>, [">= 2.3.2"])
    end
  else
    s.add_dependency(%q<activesupport>, [">= 2.0.2"])
    s.add_dependency(%q<nokogiri>, [">= 1.2.3"])
    s.add_dependency(%q<hoe>, [">= 2.3.2"])
  end
end
