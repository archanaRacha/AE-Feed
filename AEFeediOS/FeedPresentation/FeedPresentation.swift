//
//  FeedPresentation.swift
//  AEFeediOS
//
//  Created by archana racha on 11/09/24.
//

import AE_Feed

struct FeedLoadingViewModel{
    let isLoading:Bool
}
protocol FeedLoadingView {
    func display(_ viewModel:FeedLoadingViewModel)
}
struct FeedViewModel{
    let feed:[FeedImage]
}
protocol FeedView{
    
    func display(_ viewModel:FeedViewModel)
}

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

final class FeedPresenter {
   
    private var feedView:FeedView
    private var loadingView:FeedLoadingView
    init(feedView: FeedView, loadingView: FeedLoadingView) {
        self.feedView = feedView
        self.loadingView = loadingView
    }
    static var title: String{
        return NSLocalizedString("FEED_VIEW_TITLE",
                                 tableName: "Feed",
                                 bundle: Bundle(for: FeedPresenter.self),
                                 comment: "title for the feed view")
    }
    func didStartLoadingFeed(){
      
        loadingView.display(FeedLoadingViewModel(isLoading: true))
    }
    func didFinishedLoadingFeed(with feed:[FeedImage]){
      
        feedView.display(FeedViewModel(feed: feed))
        loadingView.display(FeedLoadingViewModel(isLoading: false))
    }
    func didFinishedLoadingFeed(with error:Error){
     
        loadingView.display(FeedLoadingViewModel(isLoading: false))
    }
    
}

