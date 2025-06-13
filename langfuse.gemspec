Gem::Specification.new do |spec|
  spec.name          = "langfuse-ruby"
  spec.version       = "0.1.0"
  spec.authors       = ["isaka1022"]
  spec.email         = ["your.email@example.com"]

  spec.summary       = "Ruby client for Langfuse API"
  spec.description   = "A Ruby gem for interacting with the Langfuse tracing and observability platform"
  spec.homepage      = "https://github.com/isaka1022/langfuse-ruby"
  spec.license       = "MIT"
  spec.required_ruby_version = ">= 2.7.0"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/isaka1022/langfuse-ruby"
  spec.metadata["changelog_uri"] = "https://github.com/isaka1022/langfuse-ruby/blob/main/CHANGELOG.md"

  spec.files = Dir.chdir(__dir__) do
    `git ls-files -z`.split("\x0").reject do |f|
      (File.expand_path(f) == __FILE__) ||
        f.start_with?(*%w[bin/ test/ spec/ features/ .git .circleci appveyor Gemfile])
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "net-http", "~> 0.3"
  spec.add_dependency "json", "~> 2.0"

  spec.add_development_dependency "bundler", "~> 2.0"
  spec.add_development_dependency "rake", "~> 13.0"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency "webmock", "~> 3.0"
end
