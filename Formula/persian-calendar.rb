class PersianCalendar < Formula
  desc "Persian Calendar"
  homepage "https://github.com/ebraminio/homebrew-apps"
  url "https://raw.githubusercontent.com/ebraminio/homebrew-apps/master/PersianCalendar.swift"
  version "0.2.2"
  sha256 "157c34fb1f52b9bf310a8dd75008c4ca6a57bc460ba613093f6d7f88796a2fd4"

  def install
    cp "persiancalendar.swift", "#{prefix}"
  end

  plist_options :startup => true

  def plist; <<-EOS
    <?xml version="1.0" encoding="UTF-8"?>
    <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
    <plist version="1.0">
      <dict>
        <key>Label</key>
        <string>#{plist_name}</string>
        <key>ProgramArguments</key>
        <array>
          <string>/usr/bin/swift</string>
          <string>#{prefix}/persiancalendar.swift</string>
        </array>
        <key>KeepAlive</key>
        <false/>
        <key>RunAtLoad</key>
        <true/>
      </dict>
    </plist>
    EOS
  end

  test do
    system "false"
  end
end
