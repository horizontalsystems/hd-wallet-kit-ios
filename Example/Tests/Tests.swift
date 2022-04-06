import XCTest
import HdWalletKit
import OpenSslKit

class Tests: XCTestCase {

    func testExample() {
        let words = try! Mnemonic.generate()
        let seed = Mnemonic.seed(mnemonic: words)
        let hdWallet = HDWallet(seed: seed, coinType: 1, xPrivKey: 1, xPubKey: 1)

        _ = try! hdWallet.privateKey(account: 1, index: 1, chain: .external)

        XCTAssert(true, "Pass")
    }

    func testPublicKeyInitializationFromExtendedPublicKeyString() {
        let words = try! Mnemonic.generate()
        let seed = Mnemonic.seed(mnemonic: words)
        let hdWallet = HDWallet(seed: seed, coinType: 1, xPrivKey: 1, xPubKey: 0x0488b21e, purpose: .bip49)

        let k = try! hdWallet.publicKeys(account: 0, indices: 0..<1, chain: .external).first!
        let extended = try! hdWallet.privateKey(path: "m/49'/1'/0'").publicKey().extended()
        let k2 = try! ReadOnlyHDWallet.publicKeys(extendedPublicKey: extended, indices: 0..<1, chain: .external).first!

        XCTAssertEqual(k.xPubKey, k2.xPubKey)
        XCTAssertEqual(k.depth, k2.depth)
        XCTAssertEqual(k.fingerprint, k2.fingerprint)
        XCTAssertEqual(k.childIndex, k2.childIndex)
        XCTAssertEqual(k.raw, k2.raw)
        XCTAssertEqual(k.chainCode, k2.chainCode)
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
