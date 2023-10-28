class PersianCalendar < Formula
  desc "Persian Calendar"
  homepage "https://github.com/ebraminio/homebrew-apps"
  url "https://raw.githubusercontent.com/ebraminio/homebrew-apps/master/PersianCalendar.swift"
  version "0.2.3"
  sha256 "f872ab697e0b6ed28ab285e2babb2513fcf51b94df3b981eb6b5533bb160ca2f"

  def install
    system "/usr/bin/swiftc", "persiancalendar.swift", "-o", "#{prefix}/persiancalendar"
  end

  service do
    run ["#{opt_prefix}/persiancalendar"]
    require_root false
  end

  test do
    system "false"
  end
end
