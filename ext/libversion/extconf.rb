require 'mkmf'

pkg_config('libversion')

create_makefile 'ruby_libversion'
