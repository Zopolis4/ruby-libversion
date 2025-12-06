# This is a pure Ruby implementation of libversion, used as a fallback when the C extension is not available.

class VersionComponent
  attr_accessor :component, :rank

  # Store the ranks in order, so that we can compare their indexes to determine which is greater.
  RANK_ORDERING = %i[lower_bound pre_release zero post_release nonzero letter_suffix upper_bound]

  def initialize(components, flags)
    # While we pass in a nil component to let determine_rank know we want padding, we set the actual value to 0 when we store it.
    @component = components[1].nil? ? '0' : components[1]

    @rank = determine_rank(components, flags)
  end

  def determine_rank(components, flags)
    # If the current component is nil, it is padding.
    if components[1].nil?
      # When we are passed the lower bound flag, all padding is the lower_bound rank.
      if flags == Libversion::VERSIONFLAG_LOWER_BOUND
        return :lower_bound
      # When we are passed the upper bound flag, all padding is the upper_bound rank.
      elsif flags == Libversion::VERSIONFLAG_UPPER_BOUND
        return :upper_bound
      # If we have not been passed either bound flag, all padding is the zero rank.
      else
        return :zero
      end
    end

    # If the current component starts with a pre-release keyword (case insensitive), it is the pre_release rank.
    return :pre_release if components[1].downcase.start_with?('alpha', 'beta', 'rc', 'pre')

    # If the current component is an integer and has a value of zero, it is the zero rank.
    return :zero if Integer(components[1], exception: false)&.zero?

    # If the current component starts with a post-release keyword (case insensitive), or if the current component
    # starts with 'p' (case insensitive) and we were given the VERSIONFLAG_P_IS_PATCH flag, it is the post_release rank.
    return :post_release if components[1].start_with?('post', 'patch', 'pl', 'errata') || (flags == Libversion::VERSIONFLAG_P_IS_PATCH && components[1][0]&.downcase == 'p')

    # If the current component is an integer and has a nonzero value, it is the nonzero rank.
    return :nonzero if Integer(components[1], exception: false)&.nonzero?

    # If the previous component is an integer, the current component is alphabetic, and the next component is not an integer, the current component is the letter_suffix rank.
    return :letter_suffix unless Integer(components[0], exception: false).nil? || components[1].match?(/[^[:alpha:]]/) || !Integer(components[2], exception: false).nil?

    # If we were given the VERSIONFLAG_ANY_IS_PATCH flag, any remaining alphabetic component is of the post_release rank.
    return :post_release if flags == Libversion::VERSIONFLAG_ANY_IS_PATCH

    # Otherwise, any remaining alphabetic component is of the pre_release rank.
    return :pre_release
  end

  def <=>(other)
    # Compare the rank of both components, and return the result unless they have the same rank.
    rank_comparison = RANK_ORDERING.index(self.rank) <=> RANK_ORDERING.index(other.rank)
    return rank_comparison unless rank_comparison.zero?

    # If both components are alphabetic, return the case-insensitive comparison of their first letters.
    return self.component[0].downcase <=> other.component[0].downcase if [self, other].none? { _1.component.match?(/[^[:alpha:]]/) }

    # If we are still here, return the integer comparison of both components.
    return self.component.to_i <=> other.component.to_i
  end

  def empty?
    @component.empty?
  end
end

module Libversion
  VERSIONFLAG_P_IS_PATCH = 1
  VERSIONFLAG_ANY_IS_PATCH = 2
  VERSIONFLAG_LOWER_BOUND = 4
  VERSIONFLAG_UPPER_BOUND = 8

  def self.version_compare4(v1, v2, v1_flags, v2_flags)
    # Parse the raw version strings into an array of VersionComponents.
    v1_components = parse_version_string(v1, v1_flags)
    v2_components = parse_version_string(v2, v2_flags)

    # Pad each version so that they are the same length prior to zipping and comparison.
    # We add additional padding to support lower and upper bounds even when the versions have an equal number of components.
    v1_components.fill(VersionComponent.new([nil, nil, nil], v1_flags), v1_components.size, v2_components.size)
    v2_components.fill(VersionComponent.new([nil, nil, nil], v2_flags), v2_components.size, v1_components.size)

    # Zip the components together for ease of comparison.
    zipped_components = v1_components.zip(v2_components)

    # Iterate over the zipped components, comparing them and returning the first nonzero result we receive.
    (0...zipped_components.size).each do |i|
      comparison_result = zipped_components[i][0] <=> zipped_components[i][1]
      return comparison_result unless comparison_result.zero?
    end

    # If we got here, every component was equal, and thus the versions are equal.
    return 0
  end

  def self.version_compare2(v1, v2)
    version_compare4(v1, v2, 0, 0)
  end

  private_class_method def self.parse_version_string(version_string, version_flags)
    # Separate the version string into all-alphabetic and all-numeric components, with all other characters treated as separators.
    # Separators are recorded as empty strings, with consecutive separators being squeezed into a single empty string.
    version_raw_components = version_string.scan(/[[:alpha:]]+|[[:digit:]]+|[^[:alnum:]]+/).map { _1.match?(/[^[:alnum:]]/) ? '' : _1 }
    # Pad the raw components with nil values so that every real component gets a turn at the centre of the tuple we pass to VersionComponent.new
    version_raw_components.prepend(nil)
    version_raw_components.append(nil)

    # Loop over the raw components in groups of 3 (so we have the information for checking letter_suffix), storing the center component
    # and its rank as a VersionComponent in version_components.
    version_components = []
    version_raw_components.each_cons(3) { version_components << VersionComponent.new(_1, version_flags) }
    # Clean up any excess empty version components.
    version_components.reject!(&:empty?)

    return version_components
  end
end
