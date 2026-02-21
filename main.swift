import Cocoa
import Foundation
import ServiceManagement

class SystemMonitor {
    private var previousCPUInfo = host_cpu_load_info()

    func getCPUUsage() -> Double {
        var size = mach_msg_type_number_t(MemoryLayout<host_cpu_load_info_data_t>.size / MemoryLayout<integer_t>.size)
        var info = host_cpu_load_info()

        let result = withUnsafeMutablePointer(to: &info) {
            $0.withMemoryRebound(to: integer_t.self, capacity: Int(size)) {
                host_statistics(mach_host_self(), HOST_CPU_LOAD_INFO, $0, &size)
            }
        }

        if result != KERN_SUCCESS { return 0.0 }

        let userDiff = Double(info.cpu_ticks.0 - previousCPUInfo.cpu_ticks.0)
        let systemDiff = Double(info.cpu_ticks.1 - previousCPUInfo.cpu_ticks.1)
        let idleDiff = Double(info.cpu_ticks.2 - previousCPUInfo.cpu_ticks.2)
        let niceDiff = Double(info.cpu_ticks.3 - previousCPUInfo.cpu_ticks.3)

        let totalTicks = userDiff + systemDiff + idleDiff + niceDiff
        let usedTicks = userDiff + systemDiff + niceDiff

        // Safety check against identical ticks
        guard totalTicks > 0 else { return 0.0 }

        let usage = usedTicks / totalTicks
        previousCPUInfo = info

        return max(0.0, min(1.0, usage))
    }
    
    func getRAMUsage() -> Double {
        var vmStats = vm_statistics64()
        var size = mach_msg_type_number_t(MemoryLayout<vm_statistics64>.size / MemoryLayout<integer_t>.size)
        
        let result = withUnsafeMutablePointer(to: &vmStats) {
            $0.withMemoryRebound(to: integer_t.self, capacity: Int(size)) {
                host_statistics64(mach_host_self(), HOST_VM_INFO64, $0, &size)
            }
        }
        
        if result != KERN_SUCCESS { return 0.0 }
        
        let pageSize = Double(vm_kernel_page_size)
        
        let activeMemory = Double(vmStats.active_count) * pageSize
        let wireMemory = Double(vmStats.wire_count) * pageSize
        let compressedMemory = Double(vmStats.compressor_page_count) * pageSize
        
        let usedMemory = activeMemory + wireMemory + compressedMemory
        
        // Use physical memory from sysctl
        var physicalMemory: UInt64 = 0
        var length = MemoryLayout<UInt64>.size
        sysctlbyname("hw.memsize", &physicalMemory, &length, nil, 0)
        
        let totalMemory = Double(physicalMemory)
        
        guard totalMemory > 0 else { return 0.0 }
        
        return max(0.0, min(1.0, usedMemory / totalMemory))
    }
}

enum AnimalTheme: String, CaseIterable {
    case classic = "Classic (🐌 🐢 🐕 🐎 🐆)"
    case cat = "Cat (😽 🐈 � 🐅 🐆)"
    case bird = "Bird (🥚 🐥 🐔 🦆 🦅)"
    case dinosaur = "Dinosaur (🦕 🦎 🐊 🦖 🐉)"
    case vehicle = "Vehicle (🛹 🚲 🛵 🚗 🚀)"
    case rabbit = "Rabbit (🐌 🐁 🐇 💨 🔥)"
    case fish = "Ocean (🦐 🐡 🐠 🐟 🦈)"
    case bear = "Bear (🐨 🐼 🐻 � 🐾)"
    case mythical = "Mythical (👽 👻 👺 🦄 🐉)"
    case bug = "Bugs (🐌 🐛 🐜 🐝 🦋)"
    case monkey = "Monkey (🦥 🐒 🐵 🦧 🦍)"
    case farm = "Farm (🐄 🐖 🐑 🐕 🐎)"
    case reptile = "Reptile (🐢 🐍 🦎 🐊 🦖)"
    case penguin = "Penguin (🧊 🐧 🦭 🐬 🐋)"
    case zombie = "Halloween (🦴 💀 🧟 🧛 🦇)"
    
    func getEmojisArray() -> [String] {
        switch self {
        case .classic:  return ["🐌", "🐢", "🐕", "🐎", "🐆"]
        case .cat:      return ["😽", "🐈", "�", "🐅", "🐆"]
        case .bird:     return ["🥚", "🐥", "🐔", "🦆", "🦅"]
        case .dinosaur: return ["🦕", "🦎", "🐊", "🦖", "🐉"]
        case .vehicle:  return ["🛹", "🚲", "🛵", "🚗", "🚀"]
        case .rabbit:   return ["🐌", "🐁", "🐇", "💨", "🔥"]
        case .fish:     return ["🦐", "🐡", "🐠", "🐟", "🦈"]
        case .bear:     return ["🐨", "🐼", "🐻", "�", "🐾"]
        case .mythical: return ["👽", "👻", "👺", "🦄", "🐉"]
        case .bug:      return ["🐌", "🐛", "🐜", "🐝", "🦋"]
        case .monkey:   return ["🦥", "🐒", "🐵", "🦧", "🦍"]
        case .farm:     return ["🐄", "🐖", "🐑", "🐕", "🐎"]
        case .reptile:  return ["🐢", "🐍", "🦎", "🐊", "🦖"]
        case .penguin:  return ["🧊", "🐧", "🦭", "🐬", "🐋"]
        case .zombie:   return ["🦴", "💀", "🧟", "🧛", "🦇"]
        }
    }
}

enum MonitorType: String, CaseIterable {
    case cpu = "Monitor: CPU"
    case ram = "Monitor: RAM"
}

enum TrackLength: String, CaseIterable {
    case short = "Track Length: Short (3)"
    case medium = "Track Length: Medium (6)"
    case long = "Track Length: Long (10)"
    
    func getValue() -> Int {
        switch self {
        case .short: return 3
        case .medium: return 6
        case .long: return 10
        }
    }
}

enum DirectionMode: String, CaseIterable {
    case pingPong = "Movement: Ping-Pong (⬅️ ➡️)"
    case forward = "Movement: Treadmill Right (➡️)"
    case backward = "Movement: Treadmill Left (⬅️)"
}

class AppDelegate: NSObject, NSApplicationDelegate {
    var statusItem: NSStatusItem!
    var animationTimer: Timer?
    var monitorTimer: Timer?
    var monitor = SystemMonitor()

    var currentUsage: Double = 0.0
    var position = 0
    var direction = 1
    
    // User Settings
    var currentTheme: AnimalTheme = .classic
    var currentMonitor: MonitorType = .cpu
    var currentTrack: TrackLength = .medium
    var currentDirectionMode: DirectionMode = .pingPong

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)

        if let button = statusItem.button {
            button.title = "Starting..."
            button.font = NSFont.monospacedSystemFont(ofSize: 13, weight: .regular)
        }

        // Load saved settings
        let defaults = UserDefaults.standard
        if let savedThemeRaw = defaults.string(forKey: "SelectedTheme"), let savedTheme = AnimalTheme(rawValue: savedThemeRaw) {
            currentTheme = savedTheme
        }
        if let savedMonitorRaw = defaults.string(forKey: "MonitorType"), let savedMonitor = MonitorType(rawValue: savedMonitorRaw) {
            currentMonitor = savedMonitor
        }
        if let savedTrackRaw = defaults.string(forKey: "TrackLength"), let savedTrack = TrackLength(rawValue: savedTrackRaw) {
            currentTrack = savedTrack
            position = min(position, currentTrack.getValue() - 1)
        }
        if let savedDirectionRaw = defaults.string(forKey: "DirectionMode"), let savedDirection = DirectionMode(rawValue: savedDirectionRaw) {
            currentDirectionMode = savedDirection
        }

        setupMenu()

        // Throw away the first reading
        _ = monitor.getCPUUsage()

        // Check Hardware every 1 second
        monitorTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            
            if self.currentMonitor == .cpu {
                self.currentUsage = self.monitor.getCPUUsage()
            } else {
                self.currentUsage = self.monitor.getRAMUsage()
            }
            
            self.updateAnimationSpeed()
        }

        updateAnimationSpeed()
    }
    
    func setupMenu() {
        let menu = NSMenu()
        
        // 1. Launch at Login
        let loginItem = NSMenuItem(title: "Launch at Login", action: #selector(toggleLaunchAtLogin(_:)), keyEquivalent: "")
        loginItem.target = self
        if #available(macOS 13.0, *) {
            loginItem.state = SMAppService.mainApp.status == .enabled ? .on : .off
        }
        menu.addItem(loginItem)
        menu.addItem(NSMenuItem.separator())
        
        // 2. Monitor Section
        menu.addItem(NSMenuItem(title: "Monitoring", action: nil, keyEquivalent: ""))
        for type in MonitorType.allCases {
            let item = NSMenuItem(title: type.rawValue, action: #selector(monitorSelected(_:)), keyEquivalent: "")
            item.target = self
            item.state = (type == currentMonitor) ? .on : .off
            item.indentationLevel = 1
            menu.addItem(item)
        }
        menu.addItem(NSMenuItem.separator())
        
        // 3. Track Length Section
        menu.addItem(NSMenuItem(title: "Track settings", action: nil, keyEquivalent: ""))
        for length in TrackLength.allCases {
            let item = NSMenuItem(title: length.rawValue, action: #selector(trackSelected(_:)), keyEquivalent: "")
            item.target = self
            item.state = (length == currentTrack) ? .on : .off
            item.indentationLevel = 1
            menu.addItem(item)
        }
        menu.addItem(NSMenuItem.separator())
        
        // 4. Direction Section
        menu.addItem(NSMenuItem(title: "Movement Direction", action: nil, keyEquivalent: ""))
        for mode in DirectionMode.allCases {
            let item = NSMenuItem(title: mode.rawValue, action: #selector(directionSelected(_:)), keyEquivalent: "")
            item.target = self
            item.state = (mode == currentDirectionMode) ? .on : .off
            item.indentationLevel = 1
            menu.addItem(item)
        }
        menu.addItem(NSMenuItem.separator())

        // 5. Animal Theme Section
        menu.addItem(NSMenuItem(title: "Animal themes", action: nil, keyEquivalent: ""))
        for theme in AnimalTheme.allCases {
            let item = NSMenuItem(title: theme.rawValue, action: #selector(themeSelected(_:)), keyEquivalent: "")
            item.target = self
            item.state = (theme == currentTheme) ? .on : .off
            item.indentationLevel = 1
            menu.addItem(item)
        }
        
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "Quit RunAnimals", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q"))
        
        statusItem.menu = menu
    }
    
    @objc func monitorSelected(_ sender: NSMenuItem) {
        if let selected = MonitorType(rawValue: sender.title) {
            currentMonitor = selected
            UserDefaults.standard.set(currentMonitor.rawValue, forKey: "MonitorType")
            forceUpdateLabel()
        }
        setupMenu()
    }
    
    @objc func trackSelected(_ sender: NSMenuItem) {
        if let selected = TrackLength(rawValue: sender.title) {
            currentTrack = selected
            UserDefaults.standard.set(currentTrack.rawValue, forKey: "TrackLength")
            // Reset position to avoid out of bounds on shrinking
            position = min(position, currentTrack.getValue() - 1)
            forceUpdateLabel()
        }
        setupMenu()
    }
    
    @objc func directionSelected(_ sender: NSMenuItem) {
        if let selected = DirectionMode(rawValue: sender.title) {
            currentDirectionMode = selected
            UserDefaults.standard.set(currentDirectionMode.rawValue, forKey: "DirectionMode")
            
            // Reset direction based on mode
            if currentDirectionMode == .forward {
                direction = 1
            } else if currentDirectionMode == .backward {
                direction = -1
            }
            
            forceUpdateLabel()
        }
        setupMenu()
    }
    
    @objc func themeSelected(_ sender: NSMenuItem) {
        if let selected = AnimalTheme(rawValue: sender.title) {
            currentTheme = selected
            UserDefaults.standard.set(currentTheme.rawValue, forKey: "SelectedTheme")
            forceUpdateLabel()
        }
        setupMenu()
    }
    
    @objc func toggleLaunchAtLogin(_ sender: NSMenuItem) {
        if #available(macOS 13.0, *) {
            do {
                if SMAppService.mainApp.status == .enabled {
                    try SMAppService.mainApp.unregister()
                } else {
                    try SMAppService.mainApp.register()
                }
            } catch {
                print("Failed to toggle Launch at Login: \(error)")
            }
        }
        setupMenu()
    }
    
    func forceUpdateLabel() {
        tickAnimation(advance: false)
    }

    func getAnimal(usage: Double) -> String {
        let emojis = currentTheme.getEmojisArray()
        
        if usage >= 0.80 { return emojis[4] }  // Max load
        if usage >= 0.60 { return emojis[3] }  // High load
        if usage >= 0.40 { return emojis[2] }  // Medium load
        if usage >= 0.20 { return emojis[1] }  // Normal load
        return emojis[0]                       // Idling
    }

    func updateAnimationSpeed() {
        animationTimer?.invalidate()

        let interval: TimeInterval
        if currentUsage >= 0.80 {
            interval = 0.05 // Level 5: Max sprint
        } else if currentUsage >= 0.60 {
            interval = 0.15 // Level 4: Run
        } else if currentUsage >= 0.40 {
            interval = 0.30 // Level 3: Jog
        } else if currentUsage >= 0.20 {
            interval = 0.60 // Level 2: Walk
        } else {
            interval = 1.00 // Level 1: Idle/Crawl
        }

        animationTimer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { [weak self] _ in
            self?.tickAnimation(advance: true)
        }
    }

    func tickAnimation(advance: Bool) {
        let animal = getAnimal(usage: currentUsage)
        let maxPos = currentTrack.getValue() - 1

        if advance {
            position += direction
            
            switch currentDirectionMode {
            case .pingPong:
                if position >= maxPos {
                    position = maxPos
                    direction = -1
                } else if position <= 0 {
                    position = 0
                    direction = 1
                }
            case .forward:
                direction = 1
                if position > maxPos {
                    position = 0
                }
            case .backward:
                direction = -1
                if position < 0 {
                    position = maxPos
                }
            }
        }

        var text = ""
        for i in 0...maxPos {
            if i == position {
                text += animal
            } else {
                text += " "
            }
        }

        let percentage = String(format: "%02d%%", Int(currentUsage * 100))
        let prefix = currentMonitor == .cpu ? "CPU:" : "RAM:"
        let fullText = "[\(text)] \(prefix)\(percentage)"

        // Color Logic
        var textColor: NSColor = .labelColor // Default system text color
        if currentUsage >= 0.80 {
            textColor = .systemRed  // Critical load
        } else if currentUsage >= 0.60 {
            textColor = .systemOrange // High load
        }

        let attributes: [NSAttributedString.Key: Any] = [
            .font: NSFont.monospacedSystemFont(ofSize: 13, weight: .regular), // Keep monospace to prevent jitter
            .foregroundColor: textColor
        ]

        let attributedTitle = NSAttributedString(string: fullText, attributes: attributes)

        if let button = statusItem.button {
            button.attributedTitle = attributedTitle
        }
    }
}

let app = NSApplication.shared
let delegate = AppDelegate()
app.delegate = delegate
app.run()
