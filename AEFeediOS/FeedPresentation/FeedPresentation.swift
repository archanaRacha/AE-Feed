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

final class FeedLoaderPresentationAdapter {
    private let feedLoader: FeedLoader
    private let presenter: FeedPresenter
    init(feedLoader: FeedLoader, presenter: FeedPresenter) {
        self.feedLoader = feedLoader
        self.presenter = presenter
    }
    func loadFeed(){
        presenter.didStartLoadingFeed()
        feedLoader.load { [weak self] result in
            switch result {
            case let .success(feed):
                self?.presenter.didFinishedLoadingFeed(with: feed)
            case let .failure(error):
                self?.presenter.didFinishedLoadingFeed(with: error)
            }
        }
    }
}
final class FeedPresenter {
   
    var feedView:FeedView?
    var loadingView:FeedLoadingView?
    func didStartLoadingFeed(){
        loadingView?.display(FeedLoadingViewModel(isLoading: true))
    }
    func didFinishedLoadingFeed(with feed:[FeedImage]){
        feedView?.display(FeedViewModel(feed: feed))
        loadingView?.display(FeedLoadingViewModel(isLoading: false))
    }
    func didFinishedLoadingFeed(with error:Error){
        loadingView?.display(FeedLoadingViewModel(isLoading: false))
    }
    
}

