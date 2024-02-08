require 'minitest/autorun'
require 'ruby_libversion'

# These test cases are taken from here:
# https://github.com/repology/libversion/blob/master/tests/compare_test.c
# The copyright notice from that file is reproduced here:
# Copyright (c)) 2017-2018 Dmitry Marakasov <amdmi3@amdmi3.ru>
class RubyLibversionTest < Minitest::Test
  def test_equality
    assert_equal(0, Libversion.version_compare2('0', '0'))
    assert_equal(0, Libversion.version_compare2('0', '0'))
    assert_equal(0, Libversion.version_compare2('0a', '0a'))
    assert_equal(0, Libversion.version_compare2('a', 'a'))
    assert_equal(0, Libversion.version_compare2('a0', 'a0'))
    assert_equal(0, Libversion.version_compare2('0a1', '0a1'))
    assert_equal(0, Libversion.version_compare2('0a1b2', '0a1b2'))
    assert_equal(0, Libversion.version_compare2('1alpha1', '1alpha1'))
    assert_equal(0, Libversion.version_compare2('foo', 'foo'))
    assert_equal(0, Libversion.version_compare2('1.2.3', '1.2.3'))
    assert_equal(0, Libversion.version_compare2('hello.world', 'hello.world'))
  end

  def test_different_number_of_components
    assert_equal(0, Libversion.version_compare2('1', '1.0'))
    assert_equal(0, Libversion.version_compare2('1', '1.0.0'))
    assert_equal(0, Libversion.version_compare2('1.0', '1.0.0'))
    assert_equal(0, Libversion.version_compare2('1.0', '1.0.0.0.0.0.0.0'))
  end

  def test_leading_zeroes
    assert_equal(0, Libversion.version_compare2('00100.00100', '100.100'))
    assert_equal(0, Libversion.version_compare2('0', '00000000000000000'))
  end

  def test_simple_comparisons
    assert_equal(-1, Libversion.version_compare2('0.0.0', '0.0.1'))
    assert_equal(-1, Libversion.version_compare2('0.0.1', '0.0.2'))
    assert_equal(-1, Libversion.version_compare2('0.0.2', '0.0.10'))
    assert_equal(-1, Libversion.version_compare2('0.0.2', '0.1.0'))
    assert_equal(-1, Libversion.version_compare2('0.0.10', '0.1.0'))
    assert_equal(-1, Libversion.version_compare2('0.1.0', '0.1.1'))
    assert_equal(-1, Libversion.version_compare2('0.1.1', '1.0.0'))
    assert_equal(-1, Libversion.version_compare2('1.0.0', '10.0.0'))
    assert_equal(-1, Libversion.version_compare2('10.0.0', '100.0.0'))
    assert_equal(-1, Libversion.version_compare2('10.10000.10000', '11.0.0'))
  end

  def test_long_numbers
    assert_equal(-1, Libversion.version_compare2('20160101', '20160102'))
    assert_equal(-1, Libversion.version_compare2('999999999999999999', '1000000000000000000'))
  end

  def test_very_long_numbers
    assert_equal(-1, Libversion.version_compare2('99999999999999999999999999999999999998', '99999999999999999999999999999999999999'))
  end

  def test_letter_addendum
    assert_equal(-1, Libversion.version_compare2('1.0', '1.0a'))
    assert_equal(-1, Libversion.version_compare2('1.0a', '1.0b'))
    assert_equal(-1, Libversion.version_compare2('1.0b', '1.1'))
  end

  def test_letter_vs_number
    assert_equal(-1, Libversion.version_compare2('a', '0'))
    assert_equal(-1, Libversion.version_compare2('1.a', '1.0'))
  end

  def test_letter_only_component
    assert_equal(-1, Libversion.version_compare2('1.0.a', '1.0.b'))
    assert_equal(-1, Libversion.version_compare2('1.0.b', '1.0.c'))
    assert_equal(-1, Libversion.version_compare2('1.0.c', '1.0'))
    assert_equal(-1, Libversion.version_compare2('1.0.c', '1.0.0'))
  end

  def test_letter_component_split
    assert_equal(0, Libversion.version_compare2('1.0a0', '1.0.a0'))
    assert_equal(0, Libversion.version_compare2('1.0beta3', '1.0.b3'))
  end

  def test_ignore_case
    assert_equal(0, Libversion.version_compare2('a', 'A'))
    assert_equal(0, Libversion.version_compare2('1alpha', '1ALPHA'))
    assert_equal(0, Libversion.version_compare2('alpha1', 'ALPHA1'))
  end

  def test_one_letter_string_shortening
    assert_equal(0, Libversion.version_compare2('a', 'alpha'))
    assert_equal(0, Libversion.version_compare2('b', 'beta'))
    assert_equal(0, Libversion.version_compare2('p', 'prerelease'))
  end

  def test_unusual_component_separators
    assert_equal(0, Libversion.version_compare2('1.0.alpha.2', '1_0_alpha_2'))
    assert_equal(0, Libversion.version_compare2('1.0.alpha.2', '1-0-alpha-2'))
    assert_equal(0, Libversion.version_compare2('1.0.alpha.2', '1,0:alpha~2'))
  end

  def test_multiple_consecutive_separators
    assert_equal(0, Libversion.version_compare2('..1....2....3..', '1.2.3'))
    assert_equal(0, Libversion.version_compare2('.-~1~-.-~2~-.', '1.2'))
    assert_equal(0, Libversion.version_compare2('.,:;~+-_', '0'))
  end

  def test_empty_string
    assert_equal(0, Libversion.version_compare2('', ''))
    assert_equal(0, Libversion.version_compare2('', '0'))
    assert_equal(-1, Libversion.version_compare2('', '1'))
  end

  def test_prerelease_sequence
    assert_equal(-1, Libversion.version_compare2('1.0alpha1', '1.0alpha2'))
    assert_equal(-1, Libversion.version_compare2('1.0alpha2', '1.0beta1'))
    assert_equal(-1, Libversion.version_compare2('1.0beta1', '1.0beta2'))
    assert_equal(-1, Libversion.version_compare2('1.0beta2', '1.0rc1'))
    assert_equal(-1, Libversion.version_compare2('1.0beta2', '1.0pre1'))
    assert_equal(-1, Libversion.version_compare2('1.0rc1', '1.0'))
    assert_equal(-1, Libversion.version_compare2('1.0pre1', '1.0'))

    assert_equal(-1, Libversion.version_compare2('1.0.alpha1', '1.0.alpha2'))
    assert_equal(-1, Libversion.version_compare2('1.0.alpha2', '1.0.beta1'))
    assert_equal(-1, Libversion.version_compare2('1.0.beta1', '1.0.beta2'))
    assert_equal(-1, Libversion.version_compare2('1.0.beta2', '1.0.rc1'))
    assert_equal(-1, Libversion.version_compare2('1.0.beta2', '1.0.pre1'))
    assert_equal(-1, Libversion.version_compare2('1.0.rc1', '1.0'))
    assert_equal(-1, Libversion.version_compare2('1.0.pre1', '1.0'))

    assert_equal(-1, Libversion.version_compare2('1.0alpha.1', '1.0alpha.2'))
    assert_equal(-1, Libversion.version_compare2('1.0alpha.2', '1.0beta.1'))
    assert_equal(-1, Libversion.version_compare2('1.0beta.1', '1.0beta.2'))
    assert_equal(-1, Libversion.version_compare2('1.0beta.2', '1.0rc.1'))
    assert_equal(-1, Libversion.version_compare2('1.0beta.2', '1.0pre.1'))
    assert_equal(-1, Libversion.version_compare2('1.0rc.1', '1.0'))
    assert_equal(-1, Libversion.version_compare2('1.0pre.1', '1.0'))

    assert_equal(-1, Libversion.version_compare2('1.0.alpha.1', '1.0.alpha.2'))
    assert_equal(-1, Libversion.version_compare2('1.0.alpha.2', '1.0.beta.1'))
    assert_equal(-1, Libversion.version_compare2('1.0.beta.1', '1.0.beta.2'))
    assert_equal(-1, Libversion.version_compare2('1.0.beta.2', '1.0.rc.1'))
    assert_equal(-1, Libversion.version_compare2('1.0.beta.2', '1.0.pre.1'))
    assert_equal(-1, Libversion.version_compare2('1.0.rc.1', '1.0'))
    assert_equal(-1, Libversion.version_compare2('1.0.pre.1', '1.0'))
  end

  def test_long_word_awareness
    assert_equal(1, Libversion.version_compare2('1.0alpha-1', '0.9'))
    assert_equal(-1, Libversion.version_compare2('1.0alpha-1', '1.0'))
    assert_equal(-1, Libversion.version_compare2('1.0alpha-1', '1.0.1'))
    assert_equal(-1, Libversion.version_compare2('1.0alpha-1', '1.1'))

    assert_equal(1, Libversion.version_compare2('1.0beta-1', '0.9'))
    assert_equal(-1, Libversion.version_compare2('1.0beta-1', '1.0'))
    assert_equal(-1, Libversion.version_compare2('1.0beta-1', '1.0.1'))
    assert_equal(-1, Libversion.version_compare2('1.0beta-1', '1.1'))

    assert_equal(1, Libversion.version_compare2('1.0pre-1', '0.9'))
    assert_equal(-1, Libversion.version_compare2('1.0pre-1', '1.0'))
    assert_equal(-1, Libversion.version_compare2('1.0pre-1', '1.0.1'))
    assert_equal(-1, Libversion.version_compare2('1.0pre-1', '1.1'))

    assert_equal(1, Libversion.version_compare2('1.0prerelease-1', '0.9'))
    assert_equal(-1, Libversion.version_compare2('1.0prerelease-1', '1.0'))
    assert_equal(-1, Libversion.version_compare2('1.0prerelease-1', '1.0.1'))
    assert_equal(-1, Libversion.version_compare2('1.0prerelease-1', '1.1'))

    assert_equal(1, Libversion.version_compare2('1.0rc-1', '0.9'))
    assert_equal(-1, Libversion.version_compare2('1.0rc-1', '1.0'))
    assert_equal(-1, Libversion.version_compare2('1.0rc-1', '1.0.1'))
    assert_equal(-1, Libversion.version_compare2('1.0rc-1', '1.1'))
  end

  def test_post_release_keyword_awareness
    assert_equal(1, Libversion.version_compare2('1.0patch1', '0.9'))
    assert_equal(1, Libversion.version_compare2('1.0patch1', '1.0'))
    assert_equal(-1, Libversion.version_compare2('1.0patch1', '1.0.1'))
    assert_equal(-1, Libversion.version_compare2('1.0patch1', '1.1'))

    assert_equal(1, Libversion.version_compare2('1.0.patch1', '0.9'))
    assert_equal(1, Libversion.version_compare2('1.0.patch1', '1.0'))
    assert_equal(-1, Libversion.version_compare2('1.0.patch1', '1.0.1'))
    assert_equal(-1, Libversion.version_compare2('1.0.patch1', '1.1'))

    assert_equal(1, Libversion.version_compare2('1.0patch.1', '0.9'))
    assert_equal(1, Libversion.version_compare2('1.0patch.1', '1.0'))
    assert_equal(-1, Libversion.version_compare2('1.0patch.1', '1.0.1'))
    assert_equal(-1, Libversion.version_compare2('1.0patch.1', '1.1'))

    assert_equal(1, Libversion.version_compare2('1.0.patch.1', '0.9'))
    assert_equal(1, Libversion.version_compare2('1.0.patch.1', '1.0'))
    assert_equal(-1, Libversion.version_compare2('1.0.patch.1', '1.0.1'))
    assert_equal(-1, Libversion.version_compare2('1.0.patch.1', '1.1'))

    assert_equal(1, Libversion.version_compare2('1.0post1', '0.9'))
    assert_equal(1, Libversion.version_compare2('1.0post1', '1.0'))
    assert_equal(-1, Libversion.version_compare2('1.0post1', '1.0.1'))
    assert_equal(-1, Libversion.version_compare2('1.0post1', '1.1'))

    assert_equal(1, Libversion.version_compare2('1.0postanythinggoeshere1', '0.9'))
    assert_equal(1, Libversion.version_compare2('1.0postanythinggoeshere1', '1.0'))
    assert_equal(-1, Libversion.version_compare2('1.0postanythinggoeshere1', '1.0.1'))
    assert_equal(-1, Libversion.version_compare2('1.0postanythinggoeshere1', '1.1'))

    assert_equal(1, Libversion.version_compare2('1.0pl1', '0.9'))
    assert_equal(1, Libversion.version_compare2('1.0pl1', '1.0'))
    assert_equal(-1, Libversion.version_compare2('1.0pl1', '1.0.1'))
    assert_equal(-1, Libversion.version_compare2('1.0pl1', '1.1'))

    assert_equal(1, Libversion.version_compare2('1.0errata1', '0.9'))
    assert_equal(1, Libversion.version_compare2('1.0errata1', '1.0'))
    assert_equal(-1, Libversion.version_compare2('1.0errata1', '1.0.1'))
    assert_equal(-1, Libversion.version_compare2('1.0errata1', '1.1'))
  end

  def test_p_is_patch_flag
    assert_equal(0, Libversion.version_compare4('1.0p1', '1.0p1', 0, 0))
    assert_equal(0, Libversion.version_compare4('1.0p1', '1.0p1', Libversion::VERSIONFLAG_P_IS_PATCH, Libversion::VERSIONFLAG_P_IS_PATCH))
    assert_equal(1, Libversion.version_compare4('1.0p1', '1.0p1', Libversion::VERSIONFLAG_P_IS_PATCH, 0))
    assert_equal(-1, Libversion.version_compare4('1.0p1', '1.0p1', 0, Libversion::VERSIONFLAG_P_IS_PATCH))

    assert_equal(0, Libversion.version_compare4('1.0p1', '1.0P1', 0, 0))
    assert_equal(0, Libversion.version_compare4('1.0p1', '1.0P1', Libversion::VERSIONFLAG_P_IS_PATCH, Libversion::VERSIONFLAG_P_IS_PATCH))

    assert_equal(1, Libversion.version_compare4('1.0', '1.0p1', 0, 0))
    assert_equal(1, Libversion.version_compare4('1.0', '1.0p1', Libversion::VERSIONFLAG_P_IS_PATCH, 0))
    assert_equal(-1, Libversion.version_compare4('1.0', '1.0p1', 0, Libversion::VERSIONFLAG_P_IS_PATCH))

    assert_equal(1, Libversion.version_compare4('1.0', '1.0.p1', 0, 0))
    assert_equal(1, Libversion.version_compare4('1.0', '1.0.p1', Libversion::VERSIONFLAG_P_IS_PATCH, 0))
    assert_equal(-1, Libversion.version_compare4('1.0', '1.0.p1', 0, Libversion::VERSIONFLAG_P_IS_PATCH))

    assert_equal(1, Libversion.version_compare4('1.0', '1.0.p.1', 0, 0))
    assert_equal(1, Libversion.version_compare4('1.0', '1.0.p.1', Libversion::VERSIONFLAG_P_IS_PATCH, 0))
    assert_equal(-1, Libversion.version_compare4('1.0', '1.0.p.1', 0, Libversion::VERSIONFLAG_P_IS_PATCH))

    assert_equal(-1, Libversion.version_compare4('1.0', '1.0p.1', 0, 0))
    assert_equal(-1, Libversion.version_compare4('1.0', '1.0p.1', Libversion::VERSIONFLAG_P_IS_PATCH, 0))
    assert_equal(-1, Libversion.version_compare4('1.0', '1.0p.1', 0, Libversion::VERSIONFLAG_P_IS_PATCH))
  end

  def test_any_is_patch_flag
    assert_equal(0, Libversion.version_compare4('1.0a1', '1.0a1', 0, 0))
    assert_equal(0, Libversion.version_compare4('1.0a1', '1.0a1', Libversion::VERSIONFLAG_ANY_IS_PATCH, Libversion::VERSIONFLAG_ANY_IS_PATCH))
    assert_equal(1, Libversion.version_compare4('1.0a1', '1.0a1', Libversion::VERSIONFLAG_ANY_IS_PATCH, 0))
    assert_equal(-1, Libversion.version_compare4('1.0a1', '1.0a1', 0, Libversion::VERSIONFLAG_ANY_IS_PATCH))

    assert_equal(1, Libversion.version_compare4('1.0', '1.0a1', 0, 0))
    assert_equal(1, Libversion.version_compare4('1.0', '1.0a1', Libversion::VERSIONFLAG_ANY_IS_PATCH, 0))
    assert_equal(-1, Libversion.version_compare4('1.0', '1.0a1', 0, Libversion::VERSIONFLAG_ANY_IS_PATCH))

    assert_equal(1, Libversion.version_compare4('1.0', '1.0.a1', 0, 0))
    assert_equal(1, Libversion.version_compare4('1.0', '1.0.a1', Libversion::VERSIONFLAG_ANY_IS_PATCH, 0))
    assert_equal(-1, Libversion.version_compare4('1.0', '1.0.a1', 0, Libversion::VERSIONFLAG_ANY_IS_PATCH))

    assert_equal(1, Libversion.version_compare4('1.0', '1.0.a.1', 0, 0))
    assert_equal(1, Libversion.version_compare4('1.0', '1.0.a.1', Libversion::VERSIONFLAG_ANY_IS_PATCH, 0))
    assert_equal(-1, Libversion.version_compare4('1.0', '1.0.a.1', 0, Libversion::VERSIONFLAG_ANY_IS_PATCH))

    assert_equal(-1, Libversion.version_compare4('1.0', '1.0a.1', 0, 0))
    assert_equal(-1, Libversion.version_compare4('1.0', '1.0a.1', Libversion::VERSIONFLAG_ANY_IS_PATCH, 0))
    assert_equal(-1, Libversion.version_compare4('1.0', '1.0a.1', 0, Libversion::VERSIONFLAG_ANY_IS_PATCH))
  end

  def test_p_patch_compatibility
    assert_equal(0, Libversion.version_compare4('1.0p1', '1.0pre1', 0, 0))
    assert_equal(-1, Libversion.version_compare4('1.0p1', '1.0patch1', 0, 0))
    assert_equal(-1, Libversion.version_compare4('1.0p1', '1.0post1', 0, 0))

    assert_equal(1, Libversion.version_compare4('1.0p1', '1.0pre1', Libversion::VERSIONFLAG_P_IS_PATCH, Libversion::VERSIONFLAG_P_IS_PATCH))
    assert_equal(0, Libversion.version_compare4('1.0p1', '1.0patch1', Libversion::VERSIONFLAG_P_IS_PATCH, Libversion::VERSIONFLAG_P_IS_PATCH))
    assert_equal(0, Libversion.version_compare4('1.0p1', '1.0post1', Libversion::VERSIONFLAG_P_IS_PATCH, Libversion::VERSIONFLAG_P_IS_PATCH))
  end

  def test_prelease_words_without_numbers
    assert_equal(-1, Libversion.version_compare2('1.0alpha', '1.0'))
    assert_equal(-1, Libversion.version_compare2('1.0.alpha', '1.0'))

    assert_equal(-1, Libversion.version_compare2('1.0beta', '1.0'))
    assert_equal(-1, Libversion.version_compare2('1.0.beta', '1.0'))

    assert_equal(-1, Libversion.version_compare2('1.0rc', '1.0'))
    assert_equal(-1, Libversion.version_compare2('1.0.rc', '1.0'))

    assert_equal(-1, Libversion.version_compare2('1.0pre', '1.0'))
    assert_equal(-1, Libversion.version_compare2('1.0.pre', '1.0'))

    assert_equal(-1, Libversion.version_compare2('1.0prerelese', '1.0'))
    assert_equal(-1, Libversion.version_compare2('1.0.prerelese', '1.0'))

    assert_equal(1, Libversion.version_compare2('1.0patch', '1.0'))
    assert_equal(1, Libversion.version_compare2('1.0.patch', '1.0'))
  end

  def test_release_bounds
    assert_equal(-1, Libversion.version_compare4('0.99999', '1.0', 0, 0))
    assert_equal(-1, Libversion.version_compare4('1.0alpha', '1.0', 0, 0))
    assert_equal(-1, Libversion.version_compare4('1.0alpha0', '1.0', 0, 0))
    assert_equal(0, Libversion.version_compare4('1.0', '1.0', 0, 0))
    assert_equal(1, Libversion.version_compare4('1.0patch', '1.0', 0, 0))
    assert_equal(1, Libversion.version_compare4('1.0patch0', '1.0', 0, 0))
    assert_equal(1, Libversion.version_compare4('1.0.1', '1.0', 0, 0))
    assert_equal(1, Libversion.version_compare4('1.1', '1.0', 0, 0))

    assert_equal(-1, Libversion.version_compare4('0.99999', '1.0', 0, Libversion::VERSIONFLAG_LOWER_BOUND))
    assert_equal(1, Libversion.version_compare4('1.0alpha', '1.0', 0, Libversion::VERSIONFLAG_LOWER_BOUND))
    assert_equal(1, Libversion.version_compare4('1.0alpha0', '1.0', 0, Libversion::VERSIONFLAG_LOWER_BOUND))
    assert_equal(1, Libversion.version_compare4('1.0', '1.0', 0, Libversion::VERSIONFLAG_LOWER_BOUND))
    assert_equal(1, Libversion.version_compare4('1.0patch', '1.0', 0, Libversion::VERSIONFLAG_LOWER_BOUND))
    assert_equal(1, Libversion.version_compare4('1.0patch0', '1.0', 0, Libversion::VERSIONFLAG_LOWER_BOUND))
    assert_equal(1, Libversion.version_compare4('1.0a', '1.0', 0, Libversion::VERSIONFLAG_LOWER_BOUND))
    assert_equal(1, Libversion.version_compare4('1.0.1', '1.0', 0, Libversion::VERSIONFLAG_LOWER_BOUND))
    assert_equal(1, Libversion.version_compare4('1.1', '1.0', 0, Libversion::VERSIONFLAG_LOWER_BOUND))

    assert_equal(-1, Libversion.version_compare4('0.99999', '1.0', 0, Libversion::VERSIONFLAG_UPPER_BOUND))
    assert_equal(-1, Libversion.version_compare4('1.0alpha', '1.0', 0, Libversion::VERSIONFLAG_UPPER_BOUND))
    assert_equal(-1, Libversion.version_compare4('1.0alpha0', '1.0', 0, Libversion::VERSIONFLAG_UPPER_BOUND))
    assert_equal(-1, Libversion.version_compare4('1.0', '1.0', 0, Libversion::VERSIONFLAG_UPPER_BOUND))
    assert_equal(-1, Libversion.version_compare4('1.0patch', '1.0', 0, Libversion::VERSIONFLAG_UPPER_BOUND))
    assert_equal(-1, Libversion.version_compare4('1.0patch0', '1.0', 0, Libversion::VERSIONFLAG_UPPER_BOUND))
    assert_equal(-1, Libversion.version_compare4('1.0a', '1.0', 0, Libversion::VERSIONFLAG_UPPER_BOUND))
    assert_equal(-1, Libversion.version_compare4('1.0.1', '1.0', 0, Libversion::VERSIONFLAG_UPPER_BOUND))
    assert_equal(1, Libversion.version_compare4('1.1', '1.0', 0, Libversion::VERSIONFLAG_UPPER_BOUND))

    assert_equal(0, Libversion.version_compare4('1.0', '1.0', Libversion::VERSIONFLAG_LOWER_BOUND, Libversion::VERSIONFLAG_LOWER_BOUND))
    assert_equal(0, Libversion.version_compare4('1.0', '1.0', Libversion::VERSIONFLAG_UPPER_BOUND, Libversion::VERSIONFLAG_UPPER_BOUND))
    assert_equal(-1, Libversion.version_compare4('1.0', '1.0', Libversion::VERSIONFLAG_LOWER_BOUND, Libversion::VERSIONFLAG_UPPER_BOUND))

    assert_equal(-1, Libversion.version_compare4('1.0', '1.1', Libversion::VERSIONFLAG_UPPER_BOUND, Libversion::VERSIONFLAG_LOWER_BOUND))

    assert_equal(1, Libversion.version_compare4('0', '0.0', Libversion::VERSIONFLAG_UPPER_BOUND, Libversion::VERSIONFLAG_UPPER_BOUND))
    assert_equal(-1, Libversion.version_compare4('0', '0.0', Libversion::VERSIONFLAG_LOWER_BOUND, Libversion::VERSIONFLAG_LOWER_BOUND))
  end

  def test_uniform_component_splitting
    assert_equal(0, Libversion.version_compare2('1.0alpha1', '1.0alpha1'))
    assert_equal(0, Libversion.version_compare2('1.0alpha1', '1.0.alpha1'))
    assert_equal(0, Libversion.version_compare2('1.0alpha1', '1.0alpha.1'))
    assert_equal(0, Libversion.version_compare2('1.0alpha1', '1.0.alpha.1'))

    assert_equal(0, Libversion.version_compare2('1.0patch1', '1.0patch1'))
    assert_equal(0, Libversion.version_compare2('1.0patch1', '1.0.patch1'))
    assert_equal(0, Libversion.version_compare2('1.0patch1', '1.0patch.1'))
    assert_equal(0, Libversion.version_compare2('1.0patch1', '1.0.patch.1'))
  end
end
