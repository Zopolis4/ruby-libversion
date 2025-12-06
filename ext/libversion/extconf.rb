require 'mkmf'

pkg_config('libversion')

# If $libs is still empty, we weren't able to find the library, so we don't build the extension.
if $libs.empty? # rubocop:disable Style/GlobalVars
  # Create a dummy Makefile, to satisfy Gem::Installer#install
  # You would think mkmf's dummy_makefile method would do this, but apparently not.
  File.write 'Makefile', <<~EOF
    .PHONY: install
    install:
  EOF
else
  create_makefile 'ruby_libversion'
end
