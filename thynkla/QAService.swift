//
//  QAService.swift
//  thynkla
//

import Foundation
import Combine
import CoreData

struct ChatMessage: Identifiable {
    enum Role { case user, assistant, system }
    let id = UUID()
    let role: Role
    let text: String
}

final class QAService: ObservableObject {
    @Published private(set) var messages: [ChatMessage] = []

    private let retriever: Retriever

    init(retriever: Retriever) {
        self.retriever = retriever
    }

    func ask(_ question: String) {
        messages.append(ChatMessage(role: .user, text: question))

        // Retrieve and synthesize an answer locally (placeholder heuristic)
        let hits = retriever.topChunks(for: question, limit: 5)
        let context = hits.map { "• \($0.text)" }.joined(separator: "\n")
        let answer: String
        if context.isEmpty {
            answer = "I couldn't find matching notes. Try different keywords."
        } else {
            answer = "Here's what I found related to your question:\n\n" + context
        }
        messages.append(ChatMessage(role: .assistant, text: answer))
    }
}

