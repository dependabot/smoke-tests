# -*- encoding: utf-8 -*-
# stub: rack 2.1.4 ruby lib

Gem::Specification.new do |s|
  s.name = "rack".freeze
  s.version = "2.1.4"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.metadata = { "bug_tracker_uri" => "https://github.com/rack/rack/issues", "changelog_uri" => "https://github.com/rack/rack/blob/master/CHANGELOG.md", "documentation_uri" => "https://rubydoc.info/github/rack/rack", "homepage_uri" => "https://rack.github.io", "mailing_list_uri" => "https://groups.google.com/forum/#!forum/rack-devel", "source_code_uri" => "https://github.com/rack/rack" } if s.respond_to? :metadata=
  s.require_paths = ["lib".freeze]
  s.authors = ["Leah Neukirchen".freeze]
  s.date = "2023-06-23"
  s.description = "Rack provides a minimal, modular and adaptable interface for developing\nweb applications in Ruby.  By wrapping HTTP requests and responses in\nthe simplest way possible, it unifies and distills the API for web\nservers, web frameworks, and software in between (the so-called\nmiddleware) into a single method call.\n\nAlso see https://rack.github.io/.\n".freeze
  s.email = "leah@vuxu.org".freeze
  s.executables = ["rackup".freeze]
  s.extra_rdoc_files = ["README.rdoc".freeze, "CHANGELOG.md".freeze]
  s.files = ["CHANGELOG.md".freeze, "MIT-LICENSE".freeze, "README.rdoc".freeze, "Rakefile".freeze, "SPEC".freeze, "bin/rackup".freeze, "contrib/rack.png".freeze, "contrib/rack.svg".freeze, "contrib/rack_logo.svg".freeze, "contrib/rdoc.css".freeze, "example/lobster.ru".freeze, "example/protectedlobster.rb".freeze, "example/protectedlobster.ru".freeze, "lib/rack".freeze, "lib/rack.rb".freeze, "lib/rack/auth".freeze, "lib/rack/auth/abstract".freeze, "lib/rack/auth/abstract/handler.rb".freeze, "lib/rack/auth/abstract/request.rb".freeze, "lib/rack/auth/basic.rb".freeze, "lib/rack/auth/digest".freeze, "lib/rack/auth/digest/md5.rb".freeze, "lib/rack/auth/digest/nonce.rb".freeze, "lib/rack/auth/digest/params.rb".freeze, "lib/rack/auth/digest/request.rb".freeze, "lib/rack/body_proxy.rb".freeze, "lib/rack/builder.rb".freeze, "lib/rack/cascade.rb".freeze, "lib/rack/chunked.rb".freeze, "lib/rack/common_logger.rb".freeze, "lib/rack/conditional_get.rb".freeze, "lib/rack/config.rb".freeze, "lib/rack/content_length.rb".freeze, "lib/rack/content_type.rb".freeze, "lib/rack/core_ext".freeze, "lib/rack/core_ext/regexp.rb".freeze, "lib/rack/deflater.rb".freeze, "lib/rack/directory.rb".freeze, "lib/rack/etag.rb".freeze, "lib/rack/events.rb".freeze, "lib/rack/file.rb".freeze, "lib/rack/files.rb".freeze, "lib/rack/handler".freeze, "lib/rack/handler.rb".freeze, "lib/rack/handler/cgi.rb".freeze, "lib/rack/handler/fastcgi.rb".freeze, "lib/rack/handler/lsws.rb".freeze, "lib/rack/handler/scgi.rb".freeze, "lib/rack/handler/thin.rb".freeze, "lib/rack/handler/webrick.rb".freeze, "lib/rack/head.rb".freeze, "lib/rack/lint.rb".freeze, "lib/rack/lobster.rb".freeze, "lib/rack/lock.rb".freeze, "lib/rack/logger.rb".freeze, "lib/rack/media_type.rb".freeze, "lib/rack/method_override.rb".freeze, "lib/rack/mime.rb".freeze, "lib/rack/mock.rb".freeze, "lib/rack/multipart".freeze, "lib/rack/multipart.rb".freeze, "lib/rack/multipart/generator.rb".freeze, "lib/rack/multipart/parser.rb".freeze, "lib/rack/multipart/uploaded_file.rb".freeze, "lib/rack/null_logger.rb".freeze, "lib/rack/query_parser.rb".freeze, "lib/rack/recursive.rb".freeze, "lib/rack/reloader.rb".freeze, "lib/rack/request.rb".freeze, "lib/rack/response.rb".freeze, "lib/rack/rewindable_input.rb".freeze, "lib/rack/runtime.rb".freeze, "lib/rack/sendfile.rb".freeze, "lib/rack/server.rb".freeze, "lib/rack/session".freeze, "lib/rack/session/abstract".freeze, "lib/rack/session/abstract/id.rb".freeze, "lib/rack/session/cookie.rb".freeze, "lib/rack/session/memcache.rb".freeze, "lib/rack/session/pool.rb".freeze, "lib/rack/show_exceptions.rb".freeze, "lib/rack/show_status.rb".freeze, "lib/rack/static.rb".freeze, "lib/rack/tempfile_reaper.rb".freeze, "lib/rack/urlmap.rb".freeze, "lib/rack/utils.rb".freeze, "rack.gemspec".freeze]
  s.homepage = "https://rack.github.io/".freeze
  s.licenses = ["MIT".freeze]
  s.required_ruby_version = Gem::Requirement.new(">= 2.2.2".freeze)
  s.rubygems_version = "3.3.26".freeze
  s.summary = "a modular Ruby webserver interface".freeze

  s.installed_by_version = "3.3.26" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4
  end

  if s.respond_to? :add_runtime_dependency then
    s.add_development_dependency(%q<minitest>.freeze, ["~> 5.0"])
    s.add_development_dependency(%q<minitest-sprint>.freeze, [">= 0"])
    s.add_development_dependency(%q<minitest-global_expectations>.freeze, [">= 0"])
    s.add_development_dependency(%q<rake>.freeze, [">= 0"])
  else
    s.add_dependency(%q<minitest>.freeze, ["~> 5.0"])
    s.add_dependency(%q<minitest-sprint>.freeze, [">= 0"])
    s.add_dependency(%q<minitest-global_expectations>.freeze, [">= 0"])
    s.add_dependency(%q<rake>.freeze, [">= 0"])
  end
end
