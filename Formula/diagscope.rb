class Diagscope < Formula
  desc "Static analyzer for Java/Kotlin projects — finds code that goes blind when things break"
  homepage "https://github.com/DiagScope/diagscope"
  url "https://github.com/DiagScope/releases/releases/download/v0.1.7/diagscope-0.1.7.jar"
  sha256 "b8491758e6bca3469cb956ccf60cdaf2b477c27167943a6b5f6e25e0854ff769"
  version "0.1.7"
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
