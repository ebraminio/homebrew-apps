class PersianCalendar < Formula
  desc "Persian Calendar"
  homepage "https://github.com/ebraminio/homebrew-apps"
  url "https://raw.githubusercontent.com/ebraminio/homebrew-apps/master/PersianCalendar.swift"
  version "0.2.2"
  sha256 "157c34fb1f52b9bf310a8dd75008c4ca6a57bc460ba613093f6d7f88796a2fd4"

  def install
    cp "persiancalendar.swift", "#{opt_prefix}"
  end

  service do
    run ["/usr/bin/swift", "#{opt_prefix}/persiancalendar.swift"]
    require_root false
  end

  test do
    system "false"
  end
end
