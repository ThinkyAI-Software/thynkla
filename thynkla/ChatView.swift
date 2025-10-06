//
//  ChatView.swift
//  thynkla
//

import SwiftUI
import CoreData

struct ChatView: View {
    @Environment(\.managedObjectContext) private var context
    @StateObject private var qa = QAService(retriever: Retriever())
    @State private var input: String = ""

    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 12) {
                    ForEach(qa.messages) { msg in
                        HStack {
                            if msg.role == .assistant { Spacer(minLength: 0) }
                            Text(msg.text)
                                .padding(12)
                                .background(msg.role == .user ? Color.accentColor.opacity(0.15) : Color.gray.opacity(0.15))
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                            if msg.role == .user { Spacer(minLength: 0) }
                        }
                    }
                }
                .padding()
            }
            HStack {
                TextField("Ask about your thoughts…", text: $input, axis: .vertical)
                    .textFieldStyle(.roundedBorder)
                Button("Send") {
                    submit()
                }
                .buttonStyle(.borderedProminent)
            }
            .padding()
        }
        .navigationTitle("Ask")
    }

    private func submit() {
        let q = input.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !q.isEmpty else { return }
        qa.ask(q)
        input = ""
    }
}

#Preview {
    NavigationStack {
        ChatView()
    }
}


