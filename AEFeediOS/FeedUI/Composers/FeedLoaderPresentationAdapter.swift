//
//  FeedLoaderPresentationAdapter.swift
//  AEFeediOS
//
//  Created by archana racha on 13/09/24.
//

import Foundation
import AE_Feed

final class FeedLoaderPresentationAdapter:FeedViewControllerDelegate {
   
    
    private let feedLoader: FeedLoader
    var presenter: FeedPresenter?
    init(feedLoader: FeedLoader) {
        self.feedLoader = feedLoader
    }
    func didRequestFeedRefresh() {
        presenter?.didStartLoadingFeed()
        feedLoader.load { [weak self] result in
            switch result {
            case let .success(feed):
                self?.presenter?.didFinishedLoadingFeed(with: feed)
            case let .failure(error):
                self?.presenter?.didFinishedLoadingFeed(with: error)
            }
        }
    }
}
