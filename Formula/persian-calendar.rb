class PersianCalendar < Formula
  desc "Persian Calendar"
  homepage "https://gist.github.com/ebraminio/72034ef7b9cc7bc54aee1cfa07e152da"
  url "https://gist.githubusercontent.com/ebraminio/72034ef7b9cc7bc54aee1cfa07e152da/raw/7d4a634ebc5fe5266faad76207b4acbdceb4d68a/PersianCalendar.swift"
  version "0.1.1"
  sha256 "211e1ef4f83e7691022c3c1b8db1e09e5430d3eb2af67f2c098728f8d40b4859"

  def install
    cp "persiancalendar.swift", "#{prefix}"
  end

  plist_options :startup => true

  def plist; <<-EOS.undent
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
