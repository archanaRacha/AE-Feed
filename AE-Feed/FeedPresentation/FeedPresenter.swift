//
//  FeedPresenter.swift
//  AE-Feed
//
//  Created by archana racha on 20/09/24.
//

import Foundation

public struct FeedErrorViewModel{
    public let message: String?
    static var noError:FeedErrorViewModel{
        return FeedErrorViewModel(message: nil)
    }
    static func error(message:String) -> FeedErrorViewModel{
        return FeedErrorViewModel(message: message)
    }
}
public struct FeedLoadingViewModel{
    public let isLoading:Bool
}
public struct FeedViewModel{
    let feed:[FeedImage]
}
public protocol FeedErrorView{
    func display(_ viewModel:FeedErrorViewModel)
}
public protocol FeedLoadingView {
    func display(_ viewModel:FeedLoadingViewModel)
}
public protocol FeedView{
    func display(_ viewModel:FeedViewModel)
}

final class FeedPresenter{
    private let feedView:FeedView
    private let loadingView:FeedLoadingView
    private let errorView:FeedErrorView
    var feedLoadError:String {
        return NSLocalizedString("FEED_VIEW_CONNECTION_ERROR",tableName: "Feed",bundle: Bundle(for: FeedPresenter.self), comment: "Error message displayed when we can't load the image feed from the server.")
    }
    public init(feedView: FeedView, loadingView: FeedLoadingView,errorView: FeedErrorView){
        self.feedView = feedView
        self.errorView = errorView
        self.loadingView = loadingView
    }
    static var title : String{
        return NSLocalizedString("FEED_VIEW_TITLE",
                                 tableName: "Feed",
                                 bundle: Bundle(for: FeedPresenter.self)
                                 ,comment: "Title for the feed view")
    }
    public func didStartLoadingFeed(){
        errorView.display(.noError)
        loadingView.display(FeedLoadingViewModel(isLoading: true))
    }
    public func didFinishedLoadingFeed(with feed:[FeedImage]){
      
        feedView.display(FeedViewModel(feed: feed))
        loadingView.display(FeedLoadingViewModel(isLoading: false))
    }
    public func didFinishedLoadingFeed(with error:Error){
        errorView.display(.error(message: feedLoadError))
        loadingView.display(FeedLoadingViewModel(isLoading: false))
    }
}
