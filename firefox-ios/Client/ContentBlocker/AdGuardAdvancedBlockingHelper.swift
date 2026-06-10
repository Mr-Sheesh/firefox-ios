// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

import Foundation
import WebKit

@MainActor
final class AdGuardAdvancedBlockingHelper: TabContentScript {
    private static let handlerName = "adGuardAdvancedBlocking"

    private weak var tab: Tab?
    private weak var blocker: FirefoxTabContentBlocker?

    init(tab: Tab, blocker: FirefoxTabContentBlocker) {
        self.tab = tab
        self.blocker = blocker
    }

    static func name() -> String {
        return "AdGuardAdvancedBlocking"
    }

    func scriptMessageHandlerNames() -> [String]? {
        return [Self.handlerName]
    }

    func userContentController(
        _ userContentController: WKUserContentController,
        didReceiveScriptMessage message: WKScriptMessage
    ) {
        guard let tab,
              let blocker,
              blocker.isEnabled,
              blocker.blockingStrengthPref == .aggressive,
              let currentURL = tab.currentURL(),
              !ContentBlocker.shared.isSafelisted(url: currentURL),
              let body = message.body as? [String: Any],
              let requestID = body["requestId"] as? String,
              let pageURLString = body["pageUrl"] as? String,
              let pageURL = URL(string: pageURLString),
              pageURL.scheme == "http" || pageURL.scheme == "https",
              let configuration = AdGuardFilterEngine.shared.lookup(
                pageURL: pageURL,
                topURL: (body["topUrl"] as? String).flatMap(URL.init(string:))
              )
        else {
            return
        }

        let payload = AdGuardAdvancedBlockingPayload(
            requestID: requestID,
            pageURL: pageURLString,
            configuration: configuration
        )
        guard let data = try? JSONEncoder().encode(payload),
              let json = String(data: data, encoding: .utf8),
              let webView = tab.webView else {
            return
        }

        webView.evaluateJavaScript(
            "window.__firefoxIOSAdGuardAdvanced?.apply(\(json))",
            in: message.frameInfo,
            in: .page
        )
    }
}

private struct AdGuardAdvancedBlockingPayload: Encodable {
    let requestID: String
    let pageURL: String
    let configuration: AdGuardAdvancedBlockingConfiguration

    enum CodingKeys: String, CodingKey {
        case requestID = "requestId"
        case pageURL
        case configuration
    }
}
