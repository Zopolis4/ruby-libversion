#include "ruby.h"
#include "libversion/version.h"

static VALUE rb_version_compare2(VALUE self, VALUE v1, VALUE v2) {
  return INT2NUM(version_compare2(StringValueCStr(v1), StringValueCStr(v2)));
}

static VALUE rb_version_compare4(VALUE self, VALUE v1, VALUE v2, VALUE v1_flags, VALUE v2_flags) {
  return INT2NUM(version_compare4(StringValueCStr(v1), StringValueCStr(v2), NUM2INT(v1_flags), NUM2INT(v2_flags)));
}

void Init_ruby_libversion(void) {
  VALUE Libversion = rb_define_module("Libversion");
  rb_define_singleton_method(Libversion, "version_compare2", rb_version_compare2, 2);
  rb_define_singleton_method(Libversion, "version_compare4", rb_version_compare4, 4);
  rb_define_const(Libversion, "VERSIONFLAG_P_IS_PATCH", INT2NUM(VERSIONFLAG_P_IS_PATCH));
  rb_define_const(Libversion, "VERSIONFLAG_ANY_IS_PATCH", INT2NUM(VERSIONFLAG_ANY_IS_PATCH));
  rb_define_const(Libversion, "VERSIONFLAG_LOWER_BOUND", INT2NUM(VERSIONFLAG_LOWER_BOUND));
  rb_define_const(Libversion, "VERSIONFLAG_UPPER_BOUND", INT2NUM(VERSIONFLAG_UPPER_BOUND));
}
