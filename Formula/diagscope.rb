class Diagscope < Formula
  desc "Static analyzer for Java/Kotlin projects — finds code that goes blind when things break"
  homepage "https://github.com/DiagScope/diagscope"
  url "https://github.com/DiagScope/releases/releases/download/v0.1.0-alpha.3/diagscope-0.1.0-alpha.3.jar"
  sha256 "13eabdbf40d5b955d02b7aa9b7a92e6c0a640ee991a91ee9fd068e1bd491d179"
  version "0.1.0-alpha.3"
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
