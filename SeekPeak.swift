import Cocoa

// MARK: - DeepSeek API Key Loading
func loadDeepSeekAPIKey() -> String? {
    if let envKey = ProcessInfo.processInfo.environment["DEEPSEEK_API_KEY"],
       !envKey.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
        return envKey.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    let localFile = "deepseek_token.txt"
    if let content = try? String(contentsOfFile: localFile, encoding: .utf8) {
        let trimmed = content.trimmingCharacters(in: .whitespacesAndNewlines)
        if !trimmed.isEmpty { return trimmed }
    }
    
    let homeDir = FileManager.default.homeDirectoryForCurrentUser
    let homeFile = homeDir.appendingPathComponent(".deepseek_token").path
    if let content = try? String(contentsOfFile: homeFile, encoding: .utf8) {
        let trimmed = content.trimmingCharacters(in: .whitespacesAndNewlines)
        if !trimmed.isEmpty { return trimmed }
    }
    
    return nil
}

let deepSeekAPIKey: String? = loadDeepSeekAPIKey()

// MARK: - DeepSeek Pricing Helpers
private func utcComponents(_ date: Date = Date()) -> (weekday: Int, hour: Int, minute: Int) {
    var calendar = Calendar(identifier: .gregorian)
    calendar.timeZone = TimeZone(identifier: "UTC")!
    let comps = calendar.dateComponents([.weekday, .hour, .minute], from: date)
    return (comps.weekday ?? 1, comps.hour ?? 0, comps.minute ?? 0)
}

func isDeepSeekPeak(_ date: Date = Date()) -> Bool {
    let (weekday, hour, _) = utcComponents(date)
    if weekday == 1 || weekday == 7 { return false }
    return (hour >= 1 && hour < 4) || (hour >= 6 && hour < 10)
}

/// Full description for the menu item (includes countdown).
func deepSeekPricingDescription(_ date: Date = Date()) -> String {
    let formatter = DateFormatter()
    formatter.dateFormat = "HH:mm"
    formatter.timeZone = TimeZone(identifier: "UTC")
    let nowStr = formatter.string(from: date)
    let countdown = deepSeekCountdownString(date)
    
    if isDeepSeekPeak(date) {
        return "⚠️ Peak pricing – \(nowStr) UTC · \(countdown)"
    } else {
        return "✅ Off‑peak (50% discount) – \(nowStr) UTC · \(countdown)"
    }
}

/// Returns a countdown string like "42m left until peak" or "15m left until off‑peak".
func deepSeekCountdownString(_ date: Date = Date()) -> String {
    let (weekday, hour, minute) = utcComponents(date)
    let totalMinutes = hour * 60 + minute
    let isWeekend = (weekday == 1 || weekday == 7)
    
    let peak1Start = 1 * 60, peak1End = 4 * 60
    let peak2Start = 6 * 60, peak2End = 10 * 60
    
    if isWeekend {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "UTC")!
        var comps = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: date)
        comps.hour = 1; comps.minute = 0
        guard var nextMonday = calendar.date(from: comps) else { return "off‑peak" }
        while calendar.component(.weekday, from: nextMonday) != 2 {
            nextMonday = calendar.date(byAdding: .day, value: 1, to: nextMonday)!
        }
        if nextMonday < date {
            nextMonday = calendar.date(byAdding: .weekOfYear, value: 1, to: nextMonday)!
        }
        let diff = calendar.dateComponents([.minute], from: date, to: nextMonday)
        let mins = diff.minute ?? 0
        return "\(mins)m until peak"
    }
    
    if totalMinutes < peak1Start {
        return "\(peak1Start - totalMinutes)m until peak"
    } else if totalMinutes < peak1End {
        return "\(peak1End - totalMinutes)m until off‑peak"
    } else if totalMinutes < peak2Start {
        return "\(peak2Start - totalMinutes)m until peak"
    } else if totalMinutes < peak2End {
        return "\(peak2End - totalMinutes)m until off‑peak"
    } else {
        let minsUntilMidnight = 24 * 60 - totalMinutes
        return "\(minsUntilMidnight + peak1Start)m until peak"
    }
}

// MARK: - Balance Fetching
func fetchDeepSeekBalance(completion: @escaping (String) -> Void) {
    guard let apiKey = deepSeekAPIKey, !apiKey.isEmpty else {
        completion("⚠️ No API key found")
        return
    }
    
    guard let url = URL(string: "https://api.deepseek.com/user/balance") else {
        completion("⚠️ Invalid URL")
        return
    }
    
    var request = URLRequest(url: url)
    request.httpMethod = "GET"
    request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
    request.setValue("application/json", forHTTPHeaderField: "Accept")
    
    URLSession.shared.dataTask(with: request) { data, response, error in
        DispatchQueue.main.async {
            if let error = error {
                completion("⚠️ \(error.localizedDescription)")
                return
            }
            
            guard let data = data else {
                completion("⚠️ No data")
                return
            }
            
            do {
                if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let isAvailable = json["is_available"] as? Bool,
                   let infos = json["balance_infos"] as? [[String: Any]] {
                    
                    let lines = infos.compactMap { info -> String? in
                        guard let currency = info["currency"] as? String,
                              let total = info["total_balance"] as? String else { return nil }
                        return "\(total) \(currency)"
                    }
                    
                    if lines.isEmpty {
                        completion("⚠️ No balance info")
                    } else {
                        let prefix = isAvailable ? "💰" : "⚠️"
                        completion("\(prefix) \(lines.joined(separator: " | "))")
                    }
                } else {
                    completion("⚠️ Parse error")
                }
            } catch {
                completion("⚠️ \(error.localizedDescription)")
            }
        }
    }.resume()
}

// MARK: - Utils
final class Utils {
    @objc func copyToClipboard(_ sender: NSMenuItem) {
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(sender.title, forType: .string)
    }
}
let utils = Utils()

// MARK: - Status Bar Setup
let shared = NSApplication.shared
let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
let menu = NSMenu()
statusItem.menu = menu

let pricingMenuItem = NSMenuItem(title: "", action: #selector(Utils.copyToClipboard(_:)), keyEquivalent: "")
pricingMenuItem.target = utils
menu.addItem(pricingMenuItem)

let balanceMenuItem = NSMenuItem(title: "💰 Loading…", action: #selector(Utils.copyToClipboard(_:)), keyEquivalent: "")
balanceMenuItem.target = utils
menu.addItem(balanceMenuItem)

menu.addItem(NSMenuItem.separator())

menu.addItem(NSMenuItem(title: "Quit", action: #selector(shared.terminate), keyEquivalent: ""))

// MARK: - Timers
Timer.scheduledTimer(withTimeInterval: 10, repeats: true) { _ in
    let now = Date()
    let isPeak = isDeepSeekPeak(now)
    
    statusItem.button?.title = isPeak ? "🐡" : "🐳"
    statusItem.button?.toolTip = isPeak
        ? "DeepSeek · Peak pricing"
        : "DeepSeek · Off‑peak (50% off)"
    
    // Full description with countdown lives in the menu.
    pricingMenuItem.title = deepSeekPricingDescription(now)
}.fire()

Timer.scheduledTimer(withTimeInterval: 300, repeats: true) { _ in
    fetchDeepSeekBalance { result in
        balanceMenuItem.title = result
    }
}.fire()

NSApp.run()
