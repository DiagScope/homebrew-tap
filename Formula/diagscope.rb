class Diagscope < Formula
  desc "Static analyzer for Java/Kotlin projects — finds code that goes blind when things break"
  homepage "https://github.com/DiagScope/diagscope"
  url "https://github.com/DiagScope/releases/releases/download/v0.1.2/diagscope-0.1.2.jar"
  sha256 "ec4def1017da7157ce551d94f77174c3d0a826dfb37ea63423f6bc158d808538"
  version "0.1.2"
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
