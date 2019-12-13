import Foundation
import OpenSslKit

public struct Mnemonic {
    public enum Strength : Int {
        case `default` = 128
        case low = 160
        case medium = 192
        case high = 224
        case veryHigh = 256
    }

    public enum Language {
        case english
        case japanese
        case korean
        case spanish
        case simplifiedChinese
        case traditionalChinese
        case french
        case italian
    }

    public enum ValidationError: Error {
        case invalidWordsCount
        case invalidWords
    }

    public static func generate(strength: Strength = .default, language: Language = .english) throws -> [String] {
        let byteCount = strength.rawValue / 8
        var bytes = Data(count: byteCount)

        let status = bytes.withUnsafeMutableBytes {
            SecRandomCopyBytes(kSecRandomDefault, byteCount, $0.baseAddress!.assumingMemoryBound(to: UInt8.self))
        }

        guard status == errSecSuccess else { throw MnemonicError.randomBytesError }
        return generate(entropy: bytes, language: language)
    }

    private static func generate(entropy : Data, language: Language = .english) -> [String] {
        let list = wordList(for: language)
        var bin = String(entropy.flatMap { ("00000000" + String($0, radix:2)).suffix(8) })

        let hash = Kit.sha256(entropy)
        let bits = entropy.count * 8
        let cs = bits / 32

        let hashbits = String(hash.flatMap { ("00000000" + String($0, radix:2)).suffix(8) })
        let checksum = String(hashbits.prefix(cs))
        bin += checksum

        var mnemonic = [String]()
        for i in 0..<(bin.count / 11) {
            let wi = Int(bin[bin.index(bin.startIndex, offsetBy: i * 11)..<bin.index(bin.startIndex, offsetBy: (i + 1) * 11)], radix: 2)!
            mnemonic.append(String(list[wi]))
        }
        return mnemonic
    }

    public static func seed(mnemonic m: [String], passphrase: String = "") -> Data {
        let mnemonic = m.joined(separator: " ").decomposedStringWithCompatibilityMapping.data(using: .utf8)!
        let salt = ("mnemonic" + passphrase).decomposedStringWithCompatibilityMapping.data(using: .utf8)!
        let seed = Kit.deriveKey(password: mnemonic, salt: salt, iterations: 2048, keyLength: 64)
        return seed
    }

    public static func validate(words: [String], strength: Strength = .default) throws {
        let requiredWordsCount = (strength.rawValue / 32) * 3

        guard words.count == requiredWordsCount else {
            throw ValidationError.invalidWordsCount
        }

        let wordsList = WordList.english.map(String.init)

        for word in words {
            guard wordsList.contains(word) else {
                throw ValidationError.invalidWords
            }
        }
    }

    private static func wordList(for language: Language) -> [String.SubSequence] {
        switch language {
        case .english:
            return WordList.english
        case .japanese:
            return WordList.japanese
        case .korean:
            return WordList.korean
        case .spanish:
            return WordList.spanish
        case .simplifiedChinese:
            return WordList.simplifiedChinese
        case .traditionalChinese:
            return WordList.traditionalChinese
        case .french:
            return WordList.french
        case .italian:
            return WordList.italian
        }
    }
}

enum MnemonicError : Error {
    case randomBytesError
}
