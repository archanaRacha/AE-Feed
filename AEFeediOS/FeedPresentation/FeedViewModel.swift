//
//  FeedViewModel.swift
//  AEFeediOS
//
//  Created by archana racha on 27/08/24.
//

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
