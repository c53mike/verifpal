# This file was generated by GoReleaser. DO NOT EDIT.
class Verifpal < Formula
  desc "Cryptographic protocol analysis for students and engineers."
  homepage "https://verifpal.com"
  version "0.17.5"
  bottle :unneeded

  if OS.mac?
    url "https://source.symbolic.software/verifpal/verifpal/uploads/4fe098f6de1974259e4e85a11701a30b/verifpal_0.17.5_macos_amd64.zip"
    sha256 "7d194cb2e8d94a8f73c0ccc897e9d045171d6a68a7dc723c3b72c51e681e2c4a"
  elsif OS.linux?
    if Hardware::CPU.intel?
      url "https://source.symbolic.software/verifpal/verifpal/uploads/31a23b8a1717ec61e760e0b78a2881c2/verifpal_0.17.5_linux_amd64.zip"
      sha256 "8906ba88304f4c47a5b25fadaa50fb2217ba54750343c3773e301598159ff262"
    end
  end

  def install
    bin.install "verifpal"
  end
end
