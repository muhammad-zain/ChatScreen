//
//  ViewController.swift
//  ChatScreen
//
//  Created by Zain Sidhu on 01/03/2022.
//

import UIKit

class ChatViewController: ZSPagingViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var textBorderView: UIView!
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var messageTextView: UITextView!
    
    private var viewModel: ChatViewModel?
    
    private var cellID = "ChatCell"

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        setupView()
        viewModel = ChatViewModel(output: self)
        handleKeyboardObservers()
        
        viewModel?.loadMessages(page: currentPage)
    }
    
    private func setupView() {
        textBorderView.layer.borderColor = UIColor.lightGray.cgColor
        collectionView.register(ChatCell.self, forCellWithReuseIdentifier: cellID)
        collectionView.alwaysBounceVertical = true
        collectionView.addkeyboardHideGesture()
    }
    
    private func handleKeyboardObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardNotification), name: UIResponder.keyboardWillShowNotification, object: nil)
              
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardNotification), name: UIResponder.keyboardWillHideNotification, object: nil)
        
    }
    
    @objc private func handleKeyboardNotification(notification: NSNotification) {
        
        if let userInfo = notification.userInfo {
            
            let keyboardFrame = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as AnyObject).cgRectValue
            print(keyboardFrame!)
            
            let isKeyboardShowing = notification.name == UIResponder.keyboardWillShowNotification
            
            bottomConstraint.constant = isKeyboardShowing ? keyboardFrame!.height : 0
            
            UIView.animate(withDuration: 0, delay: 0, options: UIView.AnimationOptions.curveEaseOut, animations: {
                
                self.view.layoutIfNeeded()
                
            }, completion: { (completed) in
                
                if isKeyboardShowing {
                    self.collectionView.scrollToLast()
                }
                
            })
        }
    }

    @IBAction func sendButtonTapped(_ sender: Any) {
        let text = messageTextView.text ?? ""
        guard text.trimmingCharacters(in: .whitespacesAndNewlines).count > 0 else { return }
        messageTextView.text = ""
        viewModel?.sendMessage(content: text)
        viewModel?.sendBotMessage()
    }
}


// MARK: - UICollectionViewDelegate & UICollectionViewDataSource
extension ChatViewController: UICollectionViewDelegate, UICollectionViewDataSource  {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel?.dataSetCount ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellID, for: indexPath) as! ChatCell
        
        let message = viewModel?.value(at: indexPath)
        
        cell.setup(message: message)
        
        return cell
    }
    
}

// MARK: - UICollectionViewDelegateFlowLayout
extension ChatViewController: UICollectionViewDelegateFlowLayout {
  
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 8, left: 0, bottom: 0, right: 0)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let defaultSize = CGSize(width: ChatCell.defaultWidth, height: ChatCell.defaultHeight)
        if let messageText = viewModel?.value(at: indexPath).content {
            let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
            let estimatedFrame = NSString(string: messageText).boundingRect(with: defaultSize, options: options, attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 18)], context: nil)
            
            return CGSize(width: view.frame.width, height: estimatedFrame.height + 20)
        }
        
        return defaultSize
        
    }
    
}

extension ChatViewController: ChatOutput {
    func notifyDataSetChange(isAllDataLoaded: Bool) {
        self.dataCount = viewModel?.dataSetCount ?? 0
        self.totalItems = (viewModel?.dataSetCount ?? 0) + (isAllDataLoaded ? 0 : 1)
    }
    
    func reloadData(scrollToLast: Bool) {
        if scrollToLast || self.currentPage == 1 {
            self.collectionView.reloadData {
                self.collectionView.scrollToLast()
            }
        } else {
            self.insertNewItems()
        }
    }
    
    func insertNewItems() {
        UIView.performWithoutAnimation {
            let contentHeight = self.collectionView!.contentSize.height
            let offsetY = self.collectionView!.contentOffset.y
            let bottomOffset = contentHeight - offsetY

            CATransaction.begin()
            CATransaction.setDisableActions(true)

            self.collectionView?.performBatchUpdates({
                var indexPaths = [IndexPath]()
                for i in 0..<Paging.perPage {
                    let index = 0 + i
                    indexPaths.append(IndexPath(row: index, section: 0))
                }
                if indexPaths.count > 0 {
                    self.collectionView!.insertItems(at: indexPaths)
                }
                }, completion: {
                    finished in
                    self.collectionView.setContentOffset(CGPoint(x: 0, y: (self.collectionView?.contentSize.height)! - bottomOffset), animated: false)
                    CATransaction.commit()
            })
        }
    }
}

extension ChatViewController : UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        let isSendBtnEnabled = !textView.text.isEmpty && textView.text.trimmingCharacters(in: .whitespacesAndNewlines).count > 0
        self.sendButton.isEnabled = isSendBtnEnabled
    }
}

extension ChatViewController : ZSPagingDelegate {
    func loadPageItems() {
        self.viewModel?.loadMessages(page: currentPage)
    }
    
    func swipeDirectionForPaging() -> UISwipeGestureRecognizer.Direction {
        return .down
    }
}
