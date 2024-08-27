//
//  FeedRefreshViewController.swift
//  AEFeediOS
//
//  Created by archana racha on 26/08/24.
//

import UIKit
import AE_Feed

final class FeedViewModel {
    typealias Observer<T> = (T) -> Void
    private var feedLoader: FeedLoader
    init(feedLoader:FeedLoader){
        self.feedLoader = feedLoader
    }
    var onLoadingStateChange:Observer<Bool>?
    var onFeedLoad:Observer<[FeedImage]>?
   
    func loadFeed() {
        onLoadingStateChange?(true)
        feedLoader.load { [weak self] result in
            if let feed = try? result.get(){
                self?.onFeedLoad?(feed)
            }
            self?.onLoadingStateChange?(false)
        }
    }
}
final class FeedRefreshViewController : NSObject {
    
    private(set) lazy var view: UIRefreshControl = binded(UIRefreshControl())
    
    private let viewModel : FeedViewModel
    
    init(viewModel:FeedViewModel) {
        self.viewModel = viewModel
    }
    @objc func refresh() {
        viewModel.loadFeed()
        
    }
    func binded(_ view: UIRefreshControl) -> UIRefreshControl{
        viewModel.onLoadingStateChange = {[weak view] isLoading in
            if isLoading{
                view?.beginRefreshing()
            }else{
               view?.endRefreshing()
            }
        }
        view.addTarget(self, action: #selector(refresh), for: .valueChanged)
        return view
    }
}

