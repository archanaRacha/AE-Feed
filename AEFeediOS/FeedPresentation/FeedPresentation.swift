//
//  FeedPresentation.swift
//  AEFeediOS
//
//  Created by archana racha on 11/09/24.
//

import AE_Feed

protocol FeedLoadingView {
    func display(isLoading:Bool)
}
protocol FeedView{
    
    func display(feed:[FeedImage])
}
final class FeedPresenter {
    typealias Observer<T> = (T) -> Void
    private var feedLoader: FeedLoader
    init(feedLoader:FeedLoader){
        self.feedLoader = feedLoader
    }
    var feedView:FeedView?
    var loadingView:FeedLoadingView?
   
    func loadFeed() {
        loadingView?.display(isLoading: true)
        feedLoader.load { [weak self] result in
            if let feed = try? result.get(){
                
                self?.feedView?.display(feed: feed)
            }
            self?.loadingView?.display(isLoading: false)
        }
    }
}

