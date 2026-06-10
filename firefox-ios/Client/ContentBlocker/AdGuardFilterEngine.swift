// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

import Common
import ContentBlockerConverter
import CryptoKit
import FilterEngine
import Foundation

struct AdGuardAdvancedBlockingConfiguration: Encodable, Equatable {
    struct Scriptlet: Encodable, Equatable {
        let name: String
        let args: [String]
    }

    let css: [String]
    let extendedCss: [String]
    let js: [String]
    let scriptlets: [Scriptlet]

    init(configuration: WebExtension.Configuration) {
        css = configuration.css
        extendedCss = configuration.extendedCss
        js = configuration.js
        scriptlets = configuration.scriptlets.map {
            Scriptlet(name: $0.name, args: $0.args)
        }
    }
}

final class AdGuardFilterEngine: @unchecked Sendable {
    static let shared = AdGuardFilterEngine()

    private static let rulesResourceName = "adguard-advanced-rules"
    private static let rulesHashKey = "adguard.filterengine.rules-hash"

    private let lock = NSLock()
    private let logger: Common.Logger
    private var isPreparing = false
    private var webExtension: WebExtension?

    init(logger: Common.Logger = DefaultLogger.shared) {
        self.logger = logger
    }

    func prepare() {
        lock.lock()
        guard !isPreparing, webExtension == nil else {
            lock.unlock()
            return
        }
        isPreparing = true
        lock.unlock()

        DispatchQueue.global(qos: .utility).async { [weak self] in
            self?.prepareEngine()
        }
    }

    func lookup(pageURL: URL, topURL: URL?) -> AdGuardAdvancedBlockingConfiguration? {
        lock.lock()
        defer { lock.unlock() }

        guard let configuration = webExtension?.lookup(pageUrl: pageURL, topUrl: topURL) else {
            return nil
        }
        return AdGuardAdvancedBlockingConfiguration(configuration: configuration)
    }

    private func prepareEngine() {
        defer {
            lock.lock()
            isPreparing = false
            lock.unlock()
        }

        do {
            let fileManager = FileManager.default
            guard let rulesURL = Bundle.main.url(
                forResource: Self.rulesResourceName,
                withExtension: "txt"
            ) else {
                logger.log("AdGuard advanced rules are missing.", level: .warning, category: .adblock)
                return
            }

            let rulesData = try Data(contentsOf: rulesURL)
            guard let rules = String(data: rulesData, encoding: .utf8) else {
                logger.log("AdGuard advanced rules are not UTF-8.", level: .warning, category: .adblock)
                return
            }

            let containerURL = try fileManager.url(
                for: .applicationSupportDirectory,
                in: .userDomainMask,
                appropriateFor: nil,
                create: true
            ).appendingPathComponent("AdGuardFilterEngine", isDirectory: true)
            let extensionEngine = try WebExtension(containerURL: containerURL)
            let rulesHash = SHA256.hash(data: rulesData)
                .map { String(format: "%02x", $0) }
                .joined()
            let metaURL = containerURL
                .appendingPathComponent(Schema.BASE_DIR, isDirectory: true)
                .appendingPathComponent(Schema.ENGINE_META_FILE_NAME)
            let cachedHash = UserDefaults.standard.string(forKey: Self.rulesHashKey)

            if cachedHash != rulesHash || !fileManager.fileExists(atPath: metaURL.path) {
                _ = try extensionEngine.buildFilterEngine(rules: rules)
                UserDefaults.standard.set(rulesHash, forKey: Self.rulesHashKey)
            }

            lock.lock()
            webExtension = extensionEngine
            lock.unlock()
            logger.log("AdGuard advanced filter engine is ready.", level: .info, category: .adblock)
        } catch {
            logger.log(
                "Failed to prepare AdGuard advanced filter engine: \(error)",
                level: .warning,
                category: .adblock
            )
        }
    }
}
