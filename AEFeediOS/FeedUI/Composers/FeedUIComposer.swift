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
        let refreshController = FeedRefreshViewController(delegate: presentationAdapter)
        let feedController = FeedViewController(refreshController: refreshController)
        presentationAdapter.presenter = FeedPresenter(feedView: FeedViewAdapter(controller: feedController, imageLoader: imageLoader), loadingView: WeakRefVirtualProxy(object: refreshController))
       
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
            FeedImageCellController(viewModel: FeedImageViewModel(model: model, imageLoader: imageLoader,imageTransformer:UIImage.init))
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
