class Diagscope < Formula
  desc "Static analyzer for Java/Kotlin projects — finds code that goes blind when things break"
  homepage "https://github.com/DiagScope/diagscope"
  url "https://github.com/DiagScope/releases/releases/download/v0.1.3/diagscope-0.1.3.jar"
  sha256 "c3d72dd5e2aaa249dd688ac52214939580033494242cc180c9d813a5abd02703"
  version "0.1.3"
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
