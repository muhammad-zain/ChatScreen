//
//  ChatViewModel.swift
//  ChatScreen
//
//  Created by Zain Sidhu on 01/03/2022.
//

import Foundation


protocol ChatOutput : AnyObject {
    func reloadData(scrollToLast: Bool)
    func notifyDataSetChange(isAllDataLoaded: Bool)
}


class ChatViewModel {
    
    private var output: ChatOutput
    
    var dataSetCount: Int {
        return messages.count
    }
    
    private var messages : [Message] = []
    
    init(output: ChatOutput) {
        self.output = output
    }
    
    func loadMessages(page: Int) {
        let messages = Message.getMessages(page: page) ??  []
        
        self.messages.insert(contentsOf: messages, at: 0)
        self.output.reloadData(scrollToLast: false)
        self.output.notifyDataSetChange(isAllDataLoaded: messages.count < Paging.perPage)
    }
    
    func value(at index: IndexPath) -> Message {
        return messages[index.row]
    }
    
    func sendBotMessage() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.sendMessage(content: self.getRandomMessage(), type: .receiver, date: Date())
        }
    }
    
    private func getRandomMessage() -> String {
        let randomMessages: [String] = [
            "Hey! Its nice to meet you",
            "Sorry! I won't response to that.",
            "How can i help you?",
            "Nice to meeet you.",
            "Experience what I can do!",
            "Did you know that 75% of consumers in the U.S. said that they'd rather text with a business over email or phone calls?",
            "Bye"
        ]

        let range: UInt32 = UInt32(randomMessages.count)
        let randomNumber = Int(arc4random_uniform(range))
        
        return randomMessages[randomNumber]
    }
    
    func sendMessage(content: String, type: MessageType = .sender, date: Date = Date()) {
        let message = Message.create()
        message.type = type.rawValue
        message.content = content
        message.timestamp = date
        message.save()
        
        self.addMessage(message: message)
      
    }
    
    private func addMessage(message: Message) {
        self.messages.append(message)
        self.output.reloadData(scrollToLast: true)
    }
}



enum MessageType: String {
    case sender = "sender"
    case receiver = "receiver"
}
