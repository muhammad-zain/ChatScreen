//
//  ChatCell.swift
//  ChatScreen
//
//  Created by Zain Sidhu on 01/03/2022.
//

import Foundation
import UIKit

class ChatCell: UICollectionViewCell {
    
    static var defaultWidth = 250
    static var defaultHeight = 1000
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    let messageTextView: UITextView = {
        let textView = UITextView()
        textView.font = .systemFont(ofSize: 15)
        textView.showsVerticalScrollIndicator = false
        textView.showsHorizontalScrollIndicator = false
        textView.isEditable = false
        textView.text = "Sample message"
        textView.backgroundColor = UIColor.clear
        return textView
    }()
    
    let textBubbleView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 15
        view.layer.masksToBounds = true
        return view
    }()
    let bubbleImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.tintColor = UIColor(white: 0.90, alpha: 1)
        return imageView
    }()
    
    private func getBubleImageFor(type: MessageType) -> UIImage? {
        return UIImage(named: type == .sender ? "bubble_blue" : "bubble_gray")?.resizableImage(withCapInsets: UIEdgeInsets(top: 22, left: 26, bottom: 22, right: 26)).withRenderingMode(.alwaysTemplate)
    }
    
    func setupViews() {
        
        addSubview(textBubbleView)
        addSubview(messageTextView)
        
        textBubbleView.addSubview(bubbleImageView)
        
        bubbleImageView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            bubbleImageView.widthAnchor.constraint(equalTo: self.textBubbleView.widthAnchor),
            bubbleImageView.heightAnchor.constraint(equalTo: self.textBubbleView.heightAnchor),
            bubbleImageView.centerXAnchor.constraint(equalTo: self.textBubbleView.centerXAnchor),
            bubbleImageView.centerYAnchor.constraint(equalTo: self.textBubbleView.centerYAnchor)
        ])
    }
    
    func setup(message: Message?) {
        messageTextView.text = message?.content
        
        let size = CGSize(width: ChatCell.defaultWidth, height: ChatCell.defaultHeight)
        let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
        let estimatedFrame = NSString(string: message?.content ?? "").boundingRect(with: size, options: options, attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 16)], context: nil)
        
        setupMessageFor(estimatedFrame, type: MessageType(rawValue: message?.type ?? "") ?? .sender)
        
    }
    
    private func setupMessageFor(_ estimatedFrame: CGRect, type: MessageType) {
        let xPositionMessage: CGFloat = type == .sender ? (contentView.frame.width - estimatedFrame.width - 40) : 32
        let xPositionBuble: CGFloat = type == .sender ? (xPositionMessage - 10) : 12
        
        messageTextView.frame = CGRect(x: xPositionMessage, y: 0, width: estimatedFrame.width + 16, height: estimatedFrame.height + 20)
        textBubbleView.frame = CGRect(x: xPositionBuble, y: -4, width: estimatedFrame.width + 40, height: estimatedFrame.height + 26)
        
        bubbleImageView.image = getBubleImageFor(type: type)
        bubbleImageView.tintColor = type == .sender ? UIColor(red: 0, green: 137/255, blue: 249/255, alpha: 1) : UIColor(white: 0.95, alpha: 1)
        messageTextView.textColor = type == .sender ? .white : .black
    }
    
}
