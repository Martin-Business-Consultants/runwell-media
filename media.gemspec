require_relative "lib/media/version"

# The gemspec's name is the plugin's key and its table prefix (bin/rename changes it).
Gem::Specification.new do |spec|
  spec.name = "media"
  spec.version = Media::VERSION
  spec.summary = "Runwell: a library of each client's files, in folders, kept from or shared with the client"
  spec.authors = [ "Martin Business Consultants" ]
  spec.homepage = "https://github.com/Martin-Business-Consultants/runwell-media"
  spec.license = "FSL-1.1-MIT"
  spec.files = Dir["{app,config,db,lib}/**/*"]
  spec.required_ruby_version = ">= 3.3"
  spec.add_dependency "rails", ">= 8.1"
end
