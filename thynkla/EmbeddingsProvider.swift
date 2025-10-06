//
//  EmbeddingsProvider.swift
//  thynkla
//

import Foundation

#if canImport(NaturalLanguage)
import NaturalLanguage

protocol EmbeddingsProvider {
    var dimension: Int { get }
    func embedSentence(_ text: String, language: NLLanguage?) -> [Float]?
}

final class NLEmbeddingsProvider: EmbeddingsProvider {
    private let language: NLLanguage
    private let embedding: NLEmbedding?

    init(language: NLLanguage = .english) {
        self.language = language
        self.embedding = NLEmbedding.wordEmbedding(for: language)
    }

    var dimension: Int { embedding?.dimension ?? 0 }

    func embedSentence(_ text: String, language: NLLanguage? = nil) -> [Float]? {
        guard let emb = embedding else { return nil }
        var sum = [Float](repeating: 0, count: emb.dimension)
        var count = 0
        (text as NSString).enumerateSubstrings(in: NSRange(location: 0, length: text.utf16.count), options: .byWords) { (substr, _, _, _) in
            if let w = substr?.lowercased(), let v = emb.vector(for: w) {
                for i in 0..<emb.dimension { sum[i] += Float(v[i]) }
                count += 1
            }
        }
        guard count > 0 else { return nil }
        for i in 0..<sum.count { sum[i] /= Float(count) }
        return sum
    }
}

func cosineSimilarity(_ a: [Float], _ b: [Float]) -> Float {
    precondition(a.count == b.count)
    var dot: Float = 0, na: Float = 0, nb: Float = 0
    for i in 0..<a.count { dot += a[i] * b[i]; na += a[i] * a[i]; nb += b[i] * b[i] }
    let denom: Float = (na.squareRoot() * nb.squareRoot()) + Float(1e-8)
    return dot / denom
}

extension Array where Element == Float {
    func asFloat32Data() -> Data {
        var copy = self
        return Data(bytes: &copy, count: copy.count * MemoryLayout<Float>.size)
    }
}

extension Data {
    func toFloatArray() -> [Float] {
        let count = self.count / MemoryLayout<Float>.size
        return self.withUnsafeBytes { ptr in
            let buffer = ptr.bindMemory(to: Float.self)
            return Array(buffer[0..<count])
        }
    }
}

#else
protocol EmbeddingsProvider {
    var dimension: Int { get }
    func embedSentence(_ text: String, language: Any?) -> [Float]?
}

final class NLEmbeddingsProvider: EmbeddingsProvider {
    var dimension: Int { 0 }
    func embedSentence(_ text: String, language: Any? = nil) -> [Float]? { nil }
}

func cosineSimilarity(_ a: [Float], _ b: [Float]) -> Float { 0 }

extension Array where Element == Float { func asFloat32Data() -> Data { Data() } }
extension Data { func toFloatArray() -> [Float] { [] } }
#endif
