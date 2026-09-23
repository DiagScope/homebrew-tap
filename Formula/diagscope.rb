class Diagscope < Formula
  desc "Static analyzer for Java/Kotlin projects — finds code that goes blind when things break"
  homepage "https://github.com/DiagScope/diagscope"
  url "https://github.com/DiagScope/releases/releases/download/v0.1.0-alpha.8/diagscope-0.1.0-alpha.8.jar"
  sha256 "6f58c8e199b729da77a690b17279e14cb82d2e21a4aecebfc08a476bb81c89c6"
  version "0.1.0-alpha.8"
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
