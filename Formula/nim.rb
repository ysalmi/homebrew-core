class Nim < Formula
  desc "Statically typed, imperative programming language"
  homepage "http://nim-lang.org/"
  url "http://nim-lang.org/download/nim-0.15.0.tar.xz"
  sha256 "c514535050b2b2156147bbe6e23aafe07cd996b2afa2c81fa9a09e1cd8c669fb"
  head "https://github.com/nim-lang/Nim.git", :branch => "devel"

  bottle do
    cellar :any_skip_relocation
    sha256 "b9d9368c55de4683c37a387b1d5efdbf98b4e70a2376911799ac3c820b120cd3" => :sierra
    sha256 "5a3eba67354be157e9b15eecd38553b035552eae03567e693716f0f253f246e6" => :el_capitan
    sha256 "c21fc254e7b802f2bbf1190ad121c01ea48faf97f7589012cc28c0660b18c746" => :yosemite
  end

  def install
    if build.head?
      system "/bin/sh", "bootstrap.sh"
    else
      system "/bin/sh", "build.sh"
    end
    system "/bin/sh", "install.sh", prefix

    bin.install_symlink prefix/"nim/bin/nim"
    bin.install_symlink prefix/"nim/bin/nim" => "nimrod"

    # Building tools only for non-head branch
    if !build.head?
      system "bin/nim e install_tools.nims"

      target = prefix/"nim/bin"
      target.install "bin/nimble"
      target.install "dist/nimble/src/nimblepkg"
      target.install "bin/nimgrep"
      target.install "bin/nimsuggest"

      bin.install_symlink prefix/"nim/bin/nimble"
      bin.install_symlink prefix/"nim/bin/nimgrep"
      bin.install_symlink prefix/"nim/bin/nimsuggest"
    end
  end

  test do
    (testpath/"hello.nim").write <<-EOS.undent
      echo("hello")
    EOS
    assert_equal "hello", shell_output("#{bin}/nim compile --verbosity:0 --run #{testpath}/hello.nim").chomp

    (testpath/"hello.nimble").write <<-EOS.undent
      version = "0.1.0"
      author = "Author Name"
      description = "A test nimble package"
      license = "MIT"
      requires "nim >= 0.15.0"
    EOS
    assert_equal "name: \"hello\"", shell_output("#{bin}/nimble dump").split("\n")[0].chomp
  end
end
