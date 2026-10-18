class Diagscope < Formula
  desc "Static analyzer for Java/Kotlin projects — finds code that goes blind when things break"
  homepage "https://github.com/DiagScope/diagscope"
  url "https://github.com/DiagScope/releases/releases/download/v0.1.5/diagscope-0.1.5.jar"
  sha256 "259b4c09fbdd337d3799843a514112bd6ec925268afbb730cbe36868eefdf1e8"
  version "0.1.5"
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
