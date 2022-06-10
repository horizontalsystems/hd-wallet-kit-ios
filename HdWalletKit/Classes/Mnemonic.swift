import Foundation
import OpenSslKit

public struct Mnemonic {

    public enum WordCount: Int {
        case twelve = 12
        case fifteen = 15
        case eighteen = 18
        case twentyOne = 21
        case twentyFour = 24

        var bitLength: Int {
            self.rawValue / 3 * 32
        }

        var checksumLength: Int {
            self.rawValue / 3
        }
    }

    public enum Language: CaseIterable {
        case english
        case japanese
        case korean
        case spanish
        case simplifiedChinese
        case traditionalChinese
        case french
        case italian
        case czech
        case portuguese
    }

    public enum ValidationError: Error {
        case invalidWordsCount
        case invalidWord
        case invalidChecksum
    }

    enum MnemonicError : Error {
        case randomBytesError
    }

    public static func generate(wordCount: WordCount = .twelve, language: Language = .english) throws -> [String] {
        let byteCount = wordCount.bitLength / 8
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

    private static func seedBits(words: [String], list: [String]) -> String? {
        var seedBits = ""
        for word in words {
            guard let index = list.firstIndex(of: word) else {
                return nil
            }

            let binaryString = String(index, radix: 2).pad(toSize: 11)

            seedBits.append(contentsOf: binaryString)
        }
        return seedBits
    }

    public static func validate(words: [String]) throws {
        guard let wordCount = WordCount(rawValue: words.count) else {
            throw ValidationError.invalidWordsCount
        }

        // generate indices array
        let mnemonicDictionariesArray: [[String]] = Language.allCases.map { wordList(for: $0).map(String.init) }
        guard let seedBits = (mnemonicDictionariesArray.flatMap { seedBits(words: words, list: $0) }).first else {
            throw ValidationError.invalidWord
        }

        let checksumLength = words.count / 3

        guard checksumLength == wordCount.checksumLength else {
            throw ValidationError.invalidChecksum
        }

        let dataBitsLength = seedBits.count - checksumLength

        let dataBits = String(seedBits.prefix(dataBitsLength))
        let checksumBits = String(seedBits.suffix(checksumLength))

        guard let dataBytes = dataBits.bitStringToBytes() else {
            throw ValidationError.invalidChecksum
        }

        let hash = Kit.sha256(dataBytes)
        let hashBits = hash.toBitArray().joined(separator: "").prefix(checksumLength)

        guard hashBits == checksumBits else {
            throw ValidationError.invalidChecksum
        }
    }

    public static func wordList(for language: Language) -> [String.SubSequence] {
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
        case .czech:
            return WordList.czech
        case .portuguese:
            return WordList.portuguese
        }
    }
}
