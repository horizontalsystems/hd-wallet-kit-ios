import Foundation

public class HDWallet {
    private let seed: Data
    private let keychain: HDKeychain

    private let purpose: UInt32
    private let coinType: UInt32
    public var gapLimit: Int

    public init(seed: Data, coinType: UInt32, xPrivKey: UInt32, xPubKey: UInt32, gapLimit: Int = 5, purpose: Purpose = .bip44) {
        self.seed = seed
        self.gapLimit = gapLimit

        keychain = HDKeychain(seed: seed, xPrivKey: xPrivKey, xPubKey: xPubKey)
        self.purpose = purpose.rawValue
        self.coinType = coinType
    }

    public func privateKey(account: Int, index: Int, chain: Chain) throws -> HDPrivateKey {
        try privateKey(path: "m/\(purpose)'/\(coinType)'/\(account)'/\(chain.rawValue)/\(index)")
    }

    public func privateKey(path: String) throws -> HDPrivateKey {
        try keychain.derivedKey(path: path)
    }

    public func publicKey(account: Int, index: Int, chain: Chain) throws -> HDPublicKey {
        try privateKey(account: account, index: index, chain: chain).publicKey()
    }

    public func publicKeys(account: Int, indices: Range<UInt32>, chain: Chain) throws -> [HDPublicKey] {
        try keychain.derivedNonHardenedPublicKeys(path: "m/\(purpose)'/\(coinType)'/\(account)'/\(chain.rawValue)", indices: indices)
    }

    public enum Chain : Int {
        case external
        case `internal`
    }

}
