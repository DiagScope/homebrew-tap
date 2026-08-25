class Diagscope < Formula
  desc "Static analyzer for Java/Kotlin projects — finds code that goes blind when things break"
  homepage "https://github.com/DiagScope/diagscope"
  url "https://github.com/DiagScope/diagscope/releases/download/v0.1.0-alpha.1/diagscope-0.1.0-alpha.1.jar"
  sha256 "d29ad3741c22d0b4cbad5e7c56f2608e38a7e16b150f9e7881f67a3acc4362c5"
  version "0.1.0-alpha.1"
  license "Apache-2.0"

  depends_on "openjdk@25"

  def install
    libexec.install "diagscope-#{version}.jar"
    bin.write_jar_script libexec/"diagscope-#{version}.jar", "diagscope",
                         java_version: "25"
  end

  test do
    assert_match "DiagScope", shell_output("#{bin}/diagscope --version 2>&1")
  end
end
