//
//  FeedUIComposer.swift
//  AEFeediOS
//
//  Created by archana racha on 26/08/24.
//

import UIKit
import AE_Feed


public final class FeedUIComposer {
    private init() {}

    internal static func feedComposedWith(feedLoader: FeedLoader, imageLoader: FeedImageDataLoader) -> FeedViewController {
       
        let presentationAdapter = FeedLoaderPresentationAdapter.init(feedLoader: feedLoader)
        
        let bundle = Bundle(for: FeedViewController.self)
        let storyboard = UIStoryboard(name: "Feed", bundle: bundle)
        let feedController = storyboard.instantiateInitialViewController() as! FeedViewController
        feedController.title = FeedPresenter.title
        feedController.delegate = presentationAdapter
    
        presentationAdapter.presenter = FeedPresenter(feedView: FeedViewAdapter(controller: feedController, imageLoader: imageLoader), loadingView: WeakRefVirtualProxy(object: feedController))
       
        return feedController
    }

}

final class FeedViewAdapter : FeedView{
   
    
    private weak var controller :FeedViewController?
    private let imageLoader : FeedImageDataLoader
    init(controller: FeedViewController? = nil, imageLoader: FeedImageDataLoader) {
        self.controller = controller
        self.imageLoader = imageLoader
    }
    func display(_ viewModel: FeedViewModel) {
        controller?.tableModel = viewModel.feed.map { model in
            let adapter = FeedImageDataLoaderPresentationAdapter<WeakRefVirtualProxy<FeedImageCellController>,UIImage>(model:model,imageLoader:imageLoader)
            let view = FeedImageCellController(delegate: adapter)
            adapter.presenter = FeedImagePresenter(view: WeakRefVirtualProxy(object: view), imageTransformer: UIImage.init)
            return view
        }
    }
    
}

private final class WeakRefVirtualProxy<T:AnyObject> {
    private weak var object: T?
    init(object: T) {
        self.object = object
    }
}

extension WeakRefVirtualProxy:FeedLoadingView where T : FeedLoadingView{
    func display(_ viewModel: FeedLoadingViewModel) {
        object?.display(viewModel)
    }
}
extension WeakRefVirtualProxy:FeedImageView where T : FeedImageView, T.Image == UIImage{
    func display(_ model: FeedImageViewModel<UIImage>) {
        object?.display(model)
    }
}
