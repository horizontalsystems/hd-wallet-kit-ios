import Foundation

public class HDWallet {
    private let seed: Data
    private let keychain: HDKeychain

    private let purpose: UInt32
    private let coinType: UInt32
    public var gapLimit: Int

    public init(seed: Data, coinType: UInt32, xPrivKey: UInt32, xPubKey: UInt32, gapLimit: Int = 5) {
        self.seed = seed
        self.gapLimit = gapLimit

        keychain = HDKeychain(seed: seed, xPrivKey: xPrivKey, xPubKey: xPubKey)
        purpose = 44
        self.coinType = coinType
    }

    public func privateKey(account: Int, index: Int, chain: Chain) throws -> HDPrivateKey {
        return try privateKey(path: "m/\(purpose)'/\(coinType)'/\(account)'/\(chain.rawValue)/\(index)")
    }

    public func privateKey(path: String) throws -> HDPrivateKey {
        let privateKey = try keychain.derivedKey(path: path)
        return privateKey
    }

    public func publicKey(account: Int, index: Int, chain: Chain) throws -> HDPublicKey {
        return try privateKey(account: account, index: index, chain: chain).publicKey()
    }

    public enum Chain : Int {
        case external
        case `internal`
    }

}
