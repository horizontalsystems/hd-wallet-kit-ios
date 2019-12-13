import XCTest
import HdWalletKit

class Tests: XCTestCase {

    func testExample() {
        let words = try! Mnemonic.generate()
        let seed = Mnemonic.seed(mnemonic: words)
        let hdWallet = HDWallet(seed: seed, coinType: 1, xPrivKey: 1, xPubKey: 1)

        _ = try! hdWallet.privateKey(account: 1, index: 1, chain: .external)

        XCTAssert(true, "Pass")
    }

}
