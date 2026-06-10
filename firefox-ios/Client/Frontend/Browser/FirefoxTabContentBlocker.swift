// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

import Common
import WebKit
import Shared

struct ContentBlockingConfig {
    struct Prefs {
        static let StrengthKey = "prefkey.trackingprotection.strength"
        static let EnabledKey = "prefkey.trackingprotection.normalbrowsing"
    }

    struct Defaults {
        static let NormalBrowsing = !AppInfo.isChinaEdition
    }
}

enum BlockingStrength: String {
    case basic
    case strict
    case aggressive

    static let allOptions: [BlockingStrength] = [.basic, .strict, .aggressive]
}

extension BlockingStrength {
    var usesStrictBlocking: Bool {
        return self != .basic
    }

    var includesCustomBlocklists: Bool {
        return self == .aggressive
    }

    var settingStatus: String {
        switch self {
        case .basic:
            return .TrackingProtectionOptionBlockListLevelStandardStatus
        case .strict:
            return .TrackingProtectionOptionBlockListLevelStrict
        case .aggressive:
            return .TrackingProtectionOptionBlockListLevelAggressive
        }
    }

    var settingTitle: String {
        switch self {
        case .basic:
            return .TrackingProtectionOptionBlockListLevelStandard
        case .strict:
            return .TrackingProtectionOptionBlockListLevelStrict
        case .aggressive:
            return .TrackingProtectionOptionBlockListLevelAggressive
        }
    }

    var settingSubtitle: String {
        switch self {
        case .basic:
            return .TrackingProtectionStandardLevelDescription
        case .strict:
            return .TrackingProtectionStrictLevelDescription
        case .aggressive:
            return .TrackingProtectionAggressiveLevelDescription
        }
    }

    static func accessibilityId(for strength: BlockingStrength) -> String {
        switch strength {
        case .basic:
            return AccessibilityIdentifiers.Settings.TrackingProtection.basic
        case .strict:
            return AccessibilityIdentifiers.Settings.TrackingProtection.strict
        case .aggressive:
            return AccessibilityIdentifiers.Settings.TrackingProtection.aggressive
        }
    }
}

/// Firefox-specific implementation of tab content blocking.
@MainActor
final class FirefoxTabContentBlocker: TabContentBlocker, TabContentScript {
    let userPrefs: Prefs

    class func name() -> String {
        return "TrackingProtectionStats"
    }

    var isUserEnabled: Bool? {
        didSet {
            guard let tab = tab as? Tab else { return }
            setupForTab()
            TabEvent.post(.didChangeContentBlocking, for: tab)
            tab.reload()
        }
    }

    override var isEnabled: Bool {
        if let enabled = isUserEnabled {
            return enabled
        }

        return isEnabledInPref
    }

    var isEnabledInPref: Bool {
        return userPrefs.boolForKey(ContentBlockingConfig.Prefs.EnabledKey) ?? ContentBlockingConfig.Defaults.NormalBrowsing
    }

    var blockingStrengthPref: BlockingStrength {
        return userPrefs.stringForKey(ContentBlockingConfig.Prefs.StrengthKey).flatMap(BlockingStrength.init) ?? .basic
    }

    init(tab: ContentBlockerTab, prefs: Prefs) {
        userPrefs = prefs
        super.init(tab: tab)
        setupForTab()
    }

    func setupForTab(completion: (() -> Void)? = nil) {
        guard let tab = tab else { return }
        (tab as? Tab)?.refreshUserScripts()
        let rules = BlocklistFileName.listsForMode(
            strict: blockingStrengthPref.usesStrictBlocking,
            includeCustomBlocklists: blockingStrengthPref.includesCustomBlocklists
        )
        logger.log("Setup tracking protection for tab: \(tab)", level: .info, category: .adblock)
        ContentBlocker.shared.setupTrackingProtection(
            forTab: tab,
            isEnabled: isEnabled,
            rules: rules,
            completion: completion
        )
    }

    override func notifiedTabSetupRequired() {
        guard let tab = self.tab as? Tab else { return }
        self.logger.log("Notified tab setup required", level: .info, category: .adblock)
        self.setupForTab(completion: { tab.reload() })
        TabEvent.post(.didChangeContentBlocking, for: tab)
    }

    override func currentlyEnabledLists() -> [String] {
        return BlocklistFileName.listsForMode(
            strict: blockingStrengthPref.usesStrictBlocking,
            includeCustomBlocklists: blockingStrengthPref.includesCustomBlocklists
        )
    }

    override func notifyContentBlockingChanged() {
        guard let tab = tab as? Tab else { return }
        TabEvent.post(.didChangeContentBlocking, for: tab)
    }

    func noImageMode(enabled: Bool) {
        guard let tab = tab else { return }
        ContentBlocker.shared.noImageMode(enabled: enabled, forTab: tab)
    }
}

// Static methods to access user prefs for tracking protection
extension FirefoxTabContentBlocker {
    static func setTrackingProtection(enabled: Bool, prefs: Prefs) {
        let key = ContentBlockingConfig.Prefs.EnabledKey
        prefs.setBool(enabled, forKey: key)
        ContentBlocker.shared.prefsChanged()
    }

    static func isTrackingProtectionEnabled(prefs: Prefs) -> Bool {
        return prefs.boolForKey(ContentBlockingConfig.Prefs.EnabledKey) ?? ContentBlockingConfig.Defaults.NormalBrowsing
    }

    static func toggleTrackingProtectionEnabled(prefs: Prefs) {
        let isEnabled = FirefoxTabContentBlocker.isTrackingProtectionEnabled(prefs: prefs)
        setTrackingProtection(enabled: !isEnabled, prefs: prefs)
    }
}
