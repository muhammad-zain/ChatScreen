//
//  UICollectionViewExtension.swift
//  ChatScreen
//
//  Created by Zain Sidhu on 01/03/2022.
//

import UIKit

extension UICollectionView {
    func reloadData(completion: @escaping (()->())){
        UIView.animate(withDuration: 0, animations: {
            self.reloadData()
        }) { (_) in
            completion()
        }
    }
    
    func scrollToLast() {
        guard numberOfSections > 0 else {
            return
        }
        
        let lastSection = numberOfSections - 1
        
        guard numberOfItems(inSection: lastSection) > 0 else {
            return
        }
        
        let lastItemIndexPath = IndexPath(item: numberOfItems(inSection: lastSection) - 1,
                                          section: lastSection)
        scrollToItem(at: lastItemIndexPath, at: .bottom, animated: true)
        
    }
    
    func addkeyboardHideGesture() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = false
        self.addGestureRecognizer(tap)
    }
    
    @objc private func dismissKeyboard() {
        self.superview?.endEditing(true)
    }
    
}
