# This file was generated by GoReleaser. DO NOT EDIT.
class Verifpal < Formula
  desc "Cryptographic protocol analysis for students and engineers."
  homepage "https://verifpal.com"
  version "0.19.1"
  bottle :unneeded

  if OS.mac?
    url "https://source.symbolic.software/verifpal/verifpal/uploads/55376688e2bfa01bc20d4d513f7e12b6/verifpal_0.19.1_macos_amd64.zip"
    sha256 "23c75bbedcf357ebaa9e6e8260edf0f7964f47c69022702fc3fe8b5c8f800d38"
  elsif OS.linux?
    if Hardware::CPU.intel?
      url "https://source.symbolic.software/verifpal/verifpal/uploads/e4d1139cf6c451487e8d8c02a7da3375/verifpal_0.19.1_linux_amd64.zip"
      sha256 "e31a8a97d3370358521f4663ba418690e48b3f4f43cfdd6568321cd734687596"
    end
  end

  def install
    bin.install "verifpal"
  end
end
