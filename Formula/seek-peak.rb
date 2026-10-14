class SeekPeak < Formula
  desc "SeekPeak"
  homepage "https://github.com/ebraminio/homebrew-apps"
  url "https://raw.githubusercontent.com/ebraminio/homebrew-apps/master/SeekPeak.swift"
  version "0.0.1"
  sha256 "4cf4239b121e1872621815fd244fef6968139c8d65c373cad8b9b8d0c63e2800"

  def install
    system "/usr/bin/swiftc", "SeekPeak.swift", "-o", "#{prefix}/seekpeak"
  end

  service do
    run ["#{opt_prefix}/seekpeak"]
    require_root false
  end

  test do
    system "false"
  end
end
