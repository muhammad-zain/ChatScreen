//
//  ZSPagingViewController.swift
//  ChatScreen
//
//  Created by Zain Sidhu on 02/03/2022.
//

import UIKit

@objc public protocol ZSPagingDelegate: AnyObject {

    func loadPageItems()
    func swipeDirectionForPaging() -> UISwipeGestureRecognizer.Direction
    @objc optional func scrollViewScrollingStopped()
}

struct Paging {
    static let perPage : Int = 30;
}


class ZSPagingViewController: UIViewController {

    var currentPage: Int = 1
    var totalItems: Int = 0
    var dataCount: Int = 0
    weak var pagingDelegate: ZSPagingDelegate? = nil

    private var swipeDirection : UISwipeGestureRecognizer.Direction? = nil
    private var isLoadingList : Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.pagingDelegate = self as? ZSPagingDelegate;
        self.swipeDirection = self.pagingDelegate?.swipeDirectionForPaging()
        // Do any additional setup after loading the view.
    }
    
    @objc public func listRefreshed() {
        self.currentPage = 1;
        self.pagingDelegate?.loadPageItems();
    }
    
    
    public func loadNextPage() -> Bool {
        return self.loadMoreItemsForList()
    }
    
    private func loadMoreItemsForList() -> Bool {

        if !isLoadingList {
            isLoadingList = true
            if totalItems > dataCount {
                print("scrollViewLoadNextPage \(currentPage + 1)")
                
                self.currentPage += 1
                self.pagingDelegate?.loadPageItems()
                return true
            }
        }
        return false
    }
    
    //Pagination
    private func scrollViewLoadNextPage(_ scrollView: UIScrollView) {
        
        let x = scrollView.contentOffset.x
        let width = scrollView.frame.size.width

        let y = scrollView.contentOffset.y
        let height = scrollView.frame.size.height

        let size = scrollView.contentSize;

        if let direction = swipeDirection {
            if direction == .up, ((y + height) >= size.height) {
                _ = self.loadMoreItemsForList()
            }
            else if direction == .left, ((x + width) >= size.width) {
                _ = self.loadMoreItemsForList()
            }
            else if direction == .down, (y <= 0) {
                _ = self.loadMoreItemsForList()
            }
            else if direction == .right, (0 <= x) {
                _ = self.loadMoreItemsForList()
            }
        }
        
        self.pagingDelegate?.scrollViewScrollingStopped?();
    }
}

extension ZSPagingViewController: UIScrollViewDelegate {
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        self.isLoadingList = false
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        self.scrollViewLoadNextPage(scrollView);
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            self.scrollViewLoadNextPage(scrollView);
        }
    }
}
