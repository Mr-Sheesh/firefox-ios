// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

import XCTest
@testable import Client

final class ContentBlockerTests: XCTestCase {
    override func setUp() async throws {
        try await super.setUp()

        // Ensure all rules are removed from the global store prior to each test
        let expectation = XCTestExpectation()
        await ContentBlocker.shared.removeAllRulesInStore {
            expectation.fulfill()
        }
        await fulfillment(of: [expectation])
    }

    func testCompileListsNotInStore_callsCompletionHandlerSuccessfully() async {
        let expectation = XCTestExpectation()
        await ContentBlocker.shared.compileListsNotInStore {
            expectation.fulfill()
        }
        await fulfillment(of: [expectation], timeout: 2)
    }

    func testListsForMode_basicUsesBasicListsWithoutCustomBlocklists() {
        XCTAssertEqual(
            BlocklistFileName.listsForMode(strict: false),
            BlocklistFileName.basic.map { $0.filename }
        )
    }

    func testListsForMode_strictUsesStrictListsWithoutCustomBlocklists() {
        XCTAssertEqual(
            BlocklistFileName.listsForMode(strict: true),
            BlocklistFileName.strict.map { $0.filename }
        )
    }

    func testListsForMode_aggressiveAddsCustomBlocklists() {
        XCTAssertEqual(
            BlocklistFileName.listsForMode(strict: true, includeCustomBlocklists: true),
            BlocklistFileName.strict.map { $0.filename }
                + [BlocklistFileName.contentURLs.filename]
                + BlocklistFileName.customBlocklistFileNames
        )
    }

    func testAllBlocklistFileNames_includesDisconnectContentLists() {
        XCTAssertTrue(BlocklistFileName.allBlocklistFileNames.contains(BlocklistFileName.contentURLs.filename))
        XCTAssertTrue(BlocklistFileName.allBlocklistFileNames.contains(BlocklistFileName.contentCookies.filename))
    }

    func testCustomBlocklistFileNames_filtersAndSortsJSONFiles() {
        XCTAssertEqual(
            BlocklistFileName.customBlocklistFileNames(
                from: [
                    "fxcb-z.json",
                    "fxcb-adguard-base.json",
                    "fxcb-adguard-japanese.json",
                    "fxcb-a.json",
                    "fxcb-b.txt",
                    "other.json"
                ]
            ),
            [
                "fxcb-a.json",
                "fxcb-adguard-base.json",
                "fxcb-adguard-japanese.json",
                "fxcb-z.json"
            ]
        )
    }

    func testBlockingStrength_aggressiveUsesStrictBlockingAndCustomBlocklists() {
        XCTAssertTrue(BlockingStrength.aggressive.usesStrictBlocking)
        XCTAssertTrue(BlockingStrength.aggressive.includesCustomBlocklists)
        XCTAssertFalse(BlockingStrength.strict.includesCustomBlocklists)
        XCTAssertFalse(BlockingStrength.basic.usesStrictBlocking)
    }

    func testAdGuardGame8Rules_doNotInterceptEval() throws {
        let rulesURL = try XCTUnwrap(
            Bundle.main.url(forResource: "adguard-advanced-rules", withExtension: "txt")
        )
        let rules = try String(contentsOf: rulesURL, encoding: .utf8)
        let game8Rules = rules.split(separator: "\n").filter { line in
            line.split(separator: "#", maxSplits: 1).first?
                .split(separator: ",")
                .contains("game8.jp") == true
        }

        XCTAssertFalse(game8Rules.isEmpty)
        XCTAssertFalse(game8Rules.contains { line in
            line.contains("scriptlet('prevent-eval")
                || line.contains("scriptlet(\"prevent-eval")
                || line.contains("abort-current-inline-script', 'eval'")
                || line.contains("abort-current-inline-script\", \"eval\"")
        })
    }
}
