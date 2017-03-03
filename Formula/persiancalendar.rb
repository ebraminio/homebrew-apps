class Persiancalendar < Formula
  desc "Persian Calendar"
  homepage "https://gist.github.com/ebraminio/72034ef7b9cc7bc54aee1cfa07e152da"
  url "https://gist.githubusercontent.com/ebraminio/72034ef7b9cc7bc54aee1cfa07e152da/raw/eec2bd38ad80292df43492a4550ba447e441c697/PersianCalendar.swift"
  version "0.1"
  sha256 "0f079ca24755d5a4db8e9d123ed9864edaa35d5f12ce8d6c6171397c119692ab"

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
