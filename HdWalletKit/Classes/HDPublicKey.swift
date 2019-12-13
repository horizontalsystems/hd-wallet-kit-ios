import Foundation
import OpenSslKit
import Secp256k1Kit

public class HDPublicKey {
    let xPubKey: UInt32
    let depth: UInt8
    let fingerprint: UInt32
    let childIndex: UInt32

    public let raw: Data
    let chainCode: Data

    init(privateKey: HDPrivateKey, xPubKey: UInt32, compressed: Bool = true) {
        self.xPubKey = xPubKey
        self.raw = HDPublicKey.from(privateKey: privateKey.raw, compression: compressed)
        self.chainCode = privateKey.chainCode
        self.depth = 0
        self.fingerprint = 0
        self.childIndex = 0
    }

    init(privateKey: HDPrivateKey, chainCode: Data, xPubKey: UInt32, depth: UInt8, fingerprint: UInt32, childIndex: UInt32, compressed: Bool) {
        self.xPubKey = xPubKey
        self.raw = HDPublicKey.from(privateKey: privateKey.raw, compression: compressed)
        self.chainCode = chainCode
        self.depth = depth
        self.fingerprint = fingerprint
        self.childIndex = childIndex
    }

    init(raw: Data, chainCode: Data, xPubKey: UInt32, depth: UInt8, fingerprint: UInt32, childIndex: UInt32) {
        self.xPubKey = xPubKey
        self.raw = raw
        self.chainCode = chainCode
        self.depth = depth
        self.fingerprint = fingerprint
        self.childIndex = childIndex
    }

    func extended() -> String {
        var data = Data()
        data += xPubKey.bigEndian
        data += depth.littleEndian
        data += fingerprint.littleEndian
        data += childIndex.littleEndian
        data += chainCode
        data += raw
        let checksum = Kit.sha256sha256(data).prefix(4)
        return Base58.encode(data + checksum)
    }

    func derived(at index: UInt32) throws -> HDPublicKey {
        // As we use explicit parameter "hardened", do not allow higher bit set.
        if ((0x80000000 & index) != 0) {
            fatalError("invalid child index")
        }
        guard let derivedKey = Kit.derivedHDKey(hdKey: HDKey(privateKey: nil, publicKey: raw, chainCode: chainCode, depth: depth, fingerprint: fingerprint, childIndex: childIndex), at: index, hardened: false) else {
            throw DerivationError.derivateionFailed
        }
        return HDPublicKey(raw: derivedKey.publicKey!, chainCode: derivedKey.chainCode, xPubKey: xPubKey, depth: derivedKey.depth, fingerprint: derivedKey.fingerprint, childIndex: derivedKey.childIndex)
    }

    static func from(privateKey raw: Data, compression: Bool = false) -> Data {
        return Kit.createPublicKey(fromPrivateKeyData: raw, compressed: compression)
    }

}
