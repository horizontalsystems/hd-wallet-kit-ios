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

    func testBatchPublicKeyGeneration() {
        let words = try! Mnemonic.generate()
        let seed = Mnemonic.seed(mnemonic: words)
        let hdWallet = HDWallet(seed: seed, coinType: 1, xPrivKey: 1, xPubKey: 1)

        var publicKeys = [HDPublicKey]()
        for i in 0..<10 {
            publicKeys.append(try! hdWallet.publicKey(account: 0, index: i, chain: .external))
        }

        let batchPublicKeys: [HDPublicKey] = try! hdWallet.publicKeys(account: 0, indices: 0..<10, chain: .external)

        XCTAssertEqual(publicKeys.count, batchPublicKeys.count)

        for (i, p) in publicKeys.enumerated() {
            let bp = batchPublicKeys[i]

            XCTAssertEqual(p.raw, bp.raw)
        }
    }

}
