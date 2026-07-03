/// Semantic version for prompt templates.
class PromptVersion implements Comparable<PromptVersion> {
  const PromptVersion(this.major, this.minor, this.patch);

  final int major;
  final int minor;
  final int patch;

  @override
  int compareTo(final PromptVersion other) {
    if (major != other.major) return major.compareTo(other.major);
    if (minor != other.minor) return minor.compareTo(other.minor);
    return patch.compareTo(other.patch);
  }

  @override
  String toString() => '$major.$minor.$patch';
}
