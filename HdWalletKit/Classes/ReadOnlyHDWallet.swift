import OpenSslKit

public class ReadOnlyHDWallet {

    enum ParseError: Error {
        case InvalidExtendedPublicKey
        case InvalidChecksum
    }

    private static func dataTo<T>(data: Data, type: T.Type) -> T {
        data.withUnsafeBytes { $0.load(as: T.self) }
    }

    public static func publicKeys(hdPublicKey: HDPublicKey, indices: Range<UInt32>, chain: HDWallet.Chain) throws -> [HDPublicKey] {
        guard let firstIndex = indices.first, let lastIndex = indices.last else {
            return []
        }

        if (0x80000000 & firstIndex) != 0 && (0x80000000 & lastIndex) != 0 {
            DerivationError.derivateionFailed
        }

        var hdKey = HDKey(privateKey: nil, publicKey: hdPublicKey.raw, chainCode: hdPublicKey.chainCode, depth: hdPublicKey.depth, fingerprint: hdPublicKey.fingerprint, childIndex: hdPublicKey.childIndex)

        guard let derivedHdKey = Kit.derivedHDKey(hdKey: hdKey, at: UInt32(chain.rawValue), hardened: false), let publicKey = derivedHdKey.publicKey else {
            throw DerivationError.derivateionFailed
        }

        hdKey = HDKey(privateKey: nil, publicKey: publicKey, chainCode: derivedHdKey.chainCode, depth: derivedHdKey.depth, fingerprint: derivedHdKey.fingerprint, childIndex: derivedHdKey.childIndex)

        var keys = [HDPublicKey]()

        for i in indices {
            guard let key = Kit.derivedHDKey(hdKey: hdKey, at: i, hardened: false), let publicKey = key.publicKey else {
                throw DerivationError.derivateionFailed
            }

            keys.append(HDPublicKey(raw: publicKey, chainCode: derivedHdKey.chainCode, xPubKey: hdPublicKey.xPubKey, depth: key.depth, fingerprint: key.fingerprint, childIndex: key.childIndex))
        }

        return keys
    }

    public static func publicKeys(extendedPublicKey: String, indices: Range<UInt32>, chain: HDWallet.Chain) throws -> [HDPublicKey] {
        let data = Base58.decode(extendedPublicKey)

        guard data.count == 82 else {
            throw ParseError.InvalidExtendedPublicKey
        }

        let xPubKey = dataTo(data: Data(data[0..<4].reversed()), type: UInt32.self)
        let depth = dataTo(data: Data(data[4..<5]), type: UInt8.self)
        let fingerprint = dataTo(data: Data(data[5..<9]), type: UInt32.self)
        let childIndex = dataTo(data: Data(data[9..<13]), type: UInt32.self)
        let chainCode = Data(data[13..<45])
        let key = Data(data[45..<78])
        let checksum = Data(data[78..<82])

        guard checksum == Kit.sha256sha256(data.prefix(78)).prefix(4) else {
            throw ParseError.InvalidChecksum
        }

        let hdPublicKey = HDPublicKey(raw: key, chainCode: chainCode, xPubKey: xPubKey, depth: depth, fingerprint: fingerprint, childIndex: childIndex)

        return try Self.publicKeys(hdPublicKey: hdPublicKey, indices: indices, chain: chain)
    }

}
