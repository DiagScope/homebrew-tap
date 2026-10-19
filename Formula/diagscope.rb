class Diagscope < Formula
  desc "Static analyzer for Java/Kotlin projects — finds code that goes blind when things break"
  homepage "https://github.com/DiagScope/diagscope"
  url "https://github.com/DiagScope/releases/releases/download/v0.1.8/diagscope-0.1.8.jar"
  sha256 "ce4fe5c94aeeb13054d7dc5e768e405e675cfadde516f3479cddec738167c460"
  version "0.1.8"
  license "Apache-2.0"

  depends_on "openjdk@17"

  def install
    libexec.install "diagscope-#{version}.jar"
    bin.write_jar_script libexec/"diagscope-#{version}.jar", "diagscope",
                         java_version: "17"
  end

  test do
    assert_match "DiagScope", shell_output("#{bin}/diagscope --version 2>&1")
  end
end
