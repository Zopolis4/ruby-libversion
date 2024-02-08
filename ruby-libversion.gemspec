Gem::Specification.new do |spec|
  spec.name       = 'ruby-libversion'
  spec.summary    = 'Ruby bindings for libversion'
  spec.version    = '1.0.0'
  spec.license    = 'MIT'
  spec.author     = 'Maximilian Downey Twiss'
  spec.email      = 'creatorsmithmdt@.com'
  spec.homepage   = 'https://github.com/Zopolis4/ruby-libversion'
  spec.files      = `git ls-files`.split("\n")
  spec.extensions = 'ext/libversion/extconf.rb'
end
