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

final class FeedLoaderPresentationAdapter:FeedRefreshViewControllerDelegate {
   
    
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
final class FeedImageDataLoaderPresentationAdapter<View : FeedImageView,Image>: FeedImageCellControllerDelegate where View.Image == Image {
    private let model: FeedImage
    private let imageLoader : FeedImageDataLoader
    private var task: FeedImageDataLoaderTask?
    
    var presenter: FeedImagePresenter<View, Image>?
    init(model: FeedImage, imageLoader: FeedImageDataLoader) {
        self.model = model
        self.imageLoader = imageLoader
    }
    func didRequestImage() {
        presenter?.didStartLoadingImageData(for: model)
        let model = self.model
        task = imageLoader.loadImageData(from: model.url, completion: { [weak self] result in
            switch result {
            case let .success(data):
                self?.presenter?.didFinishLoadingImageData(with: data, for: model)
            case let .failure(error):
                self?.presenter?.didFinishLoadingImageData(with: error, for: model)
            }
        })
    }
    func didCancelImageRequest(){
        task?.cancel()
    }
}
final class FeedPresenter {
   
    private var feedView:FeedView
    private var loadingView:FeedLoadingView
    init(feedView: FeedView, loadingView: FeedLoadingView) {
        self.feedView = feedView
        self.loadingView = loadingView
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

