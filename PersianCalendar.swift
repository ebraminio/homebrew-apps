import Cocoa

// setup calendar and formatters
let persianDateFormatter = DateFormatter()
let persianLocale = Locale(identifier: "fa")
persianDateFormatter.locale = persianLocale
persianDateFormatter.dateFormat = "EEEE d MMMM/M Y"
let arabicDateFormatter = DateFormatter()
let arabicLocale = Locale(identifier: "ar-SA")
arabicDateFormatter.locale = arabicLocale
arabicDateFormatter.dateFormat = "EEEE d MMMM/M Y"
let gregorianDateFormatter = DateFormatter()
let gregorianLocale = Locale(identifier: "en")
gregorianDateFormatter.locale = gregorianLocale
gregorianDateFormatter.dateFormat = "EEEE d MMMM/M Y"

let titleDateFormatter = DateFormatter()
titleDateFormatter.locale = Locale(identifier: "fa")
titleDateFormatter.dateFormat = "d"

final class Utils {
    @objc func copyToClipboard(_ sender: NSMenuItem) {
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(sender.title, forType: .string)
    }
}
let utils = Utils()

// setup status bar menu
let shared = NSApplication.shared
let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
let menu = NSMenu()
menu.userInterfaceLayoutDirection = .rightToLeft
statusItem.menu = menu
let persianDateMenuItem = NSMenuItem(title: "", action: #selector(Utils.copyToClipboard(_:)), keyEquivalent: "")
persianDateMenuItem.target = utils
menu.addItem(persianDateMenuItem)
let arabicDateMenuItem = NSMenuItem(title: "", action: #selector(Utils.copyToClipboard(_:)), keyEquivalent: "")
arabicDateMenuItem.target = utils
menu.addItem(arabicDateMenuItem)
let gregorianDateMenuItem = NSMenuItem(title: "", action: #selector(Utils.copyToClipboard(_:)), keyEquivalent: "")
gregorianDateMenuItem.target = utils
menu.addItem(gregorianDateMenuItem)

// update
Timer.scheduledTimer(withTimeInterval: 10, repeats: true) { timer in
    let date = Date()
    statusItem.button?.toolTip = persianDateFormatter.string(from: date)
    persianDateMenuItem.title = persianDateFormatter.string(from: date)
    arabicDateMenuItem.title = arabicDateFormatter.string(from: date)
    gregorianDateMenuItem.title = gregorianDateFormatter.string(from: date)
    statusItem.button?.title = titleDateFormatter.string(from: date)
}.fire()

menu.addItem(NSMenuItem.separator())

// Persian months list
let persianMonthsMenuItem = NSMenuItem(title: "ماه‌های تقویم شمسی", action: nil, keyEquivalent: "")
let persianNumberFormatter = NumberFormatter()
persianNumberFormatter.locale = persianLocale
persianMonthsMenuItem.submenu = NSMenu()
persianMonthsMenuItem.submenu?.userInterfaceLayoutDirection = .rightToLeft
for (i, x) in persianDateFormatter.monthSymbols.enumerated() {
    persianMonthsMenuItem.submenu?.addItem(
        withTitle: x + " / " + (persianNumberFormatter.string(from: (i + 1) as NSNumber) ?? ""),
        action: #selector(Utils.copyToClipboard(_:)), keyEquivalent: "").target = utils
}
menu.addItem(persianMonthsMenuItem)

// Arabic months list
let arabicMonthsMenuItem = NSMenuItem(title: "ماه‌های تقویم قمری", action: nil, keyEquivalent: "")
let arabicNumberFormatter = NumberFormatter()
arabicNumberFormatter.locale = arabicLocale
arabicMonthsMenuItem.submenu = NSMenu()
arabicMonthsMenuItem.submenu?.userInterfaceLayoutDirection = .rightToLeft
for (i, x) in arabicDateFormatter.monthSymbols.enumerated() {
    arabicMonthsMenuItem.submenu?.addItem(
        withTitle: x + " / " + (arabicNumberFormatter.string(from: (i + 1) as NSNumber) ?? ""),
        action: #selector(Utils.copyToClipboard(_:)), keyEquivalent: "").target = utils
}
menu.addItem(arabicMonthsMenuItem)

// gregorian months list
let gregorianMonthsMenuItem = NSMenuItem(title: "ماه‌های تقویم میلادی", action: nil, keyEquivalent: "")
let gregorianNumberFormatter = NumberFormatter()
gregorianNumberFormatter.locale = gregorianLocale
gregorianMonthsMenuItem.submenu = NSMenu()
for (i, x) in gregorianDateFormatter.monthSymbols.enumerated() {
    gregorianMonthsMenuItem.submenu?.addItem(
        withTitle: x + " / " + (gregorianNumberFormatter.string(from: (i + 1) as NSNumber) ?? ""),
        action: #selector(Utils.copyToClipboard(_:)), keyEquivalent: "").target = utils
}
menu.addItem(gregorianMonthsMenuItem)

menu.addItem(NSMenuItem.separator())

menu.addItem(NSMenuItem(title: "خروج", action: #selector(shared.terminate), keyEquivalent: ""))

NSApp.run()
