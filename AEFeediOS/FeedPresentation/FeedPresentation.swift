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

struct FeedErrorViewModel{
    let message: String
}
protocol FeedErrorView{
    func display(_ viewModel:FeedErrorViewModel)
}
final class FeedPresenter {
   
    private let feedView:FeedView
    private let loadingView:FeedLoadingView
    private let errorView:FeedErrorView
    init(feedView: FeedView, loadingView: FeedLoadingView,errorView:FeedErrorView) {
        self.feedView = feedView
        self.loadingView = loadingView
        self.errorView = errorView
    }
    static var title: String{
        return NSLocalizedString("FEED_VIEW_TITLE",
                                 tableName: "Feed",
                                 bundle: Bundle(for: FeedPresenter.self),
                                 comment: "title for the feed view")
    }
    private var feedLoadError:String {
        return NSLocalizedString("FEED_VIEW_CONNECTION_ERROR",tableName: "Feed",bundle: Bundle(for: FeedPresenter.self), comment: "Error message displayed when we can't load the image feed from the server.")
    }
    func didStartLoadingFeed(){
      
        loadingView.display(FeedLoadingViewModel(isLoading: true))
    }
    func didFinishedLoadingFeed(with feed:[FeedImage]){
      
        feedView.display(FeedViewModel(feed: feed))
        loadingView.display(FeedLoadingViewModel(isLoading: false))
    }
    func didFinishedLoadingFeed(with error:Error){
        errorView.display(FeedErrorViewModel(message: feedLoadError))
        loadingView.display(FeedLoadingViewModel(isLoading: false))
    }
    
}

