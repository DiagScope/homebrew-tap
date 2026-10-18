class Diagscope < Formula
  desc "Static analyzer for Java/Kotlin projects — finds code that goes blind when things break"
  homepage "https://github.com/DiagScope/diagscope"
  url "https://github.com/DiagScope/releases/releases/download/v0.1.6/diagscope-0.1.6.jar"
  sha256 "600732e7e3479a91c7d96b1386a2bc233263094ea5909c176fe8729e68b703a9"
  version "0.1.6"
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
