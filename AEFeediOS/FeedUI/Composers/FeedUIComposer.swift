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
       
        let presentationAdapter = FeedLoaderPresentationAdapter.init(feedLoader: MainQueueDispatchDecorator(decoratee: feedLoader))
        let feedController = FeedViewController.makeWith(delegate: presentationAdapter, title: FeedPresenter.title)
        presentationAdapter.presenter = FeedPresenter(feedView: FeedViewAdapter(controller: feedController, imageLoader: imageLoader), loadingView: WeakRefVirtualProxy(object: feedController))
       
        return feedController
    }

}
private final class MainQueueDispatchDecorator: FeedLoader {
    private let decoratee: FeedLoader

    init(decoratee: FeedLoader) {
        self.decoratee = decoratee
    }

    func load(completion: @escaping (FeedLoader.Result) -> Void) {
        decoratee.load { result in
            if Thread.isMainThread {
                completion(result)
            } else {
                DispatchQueue.main.async {
                    completion(result)
                }
            }
        }
    }
}
private extension FeedViewController{
    static func makeWith(delegate:FeedViewControllerDelegate, title:String) -> FeedViewController{
        let bundle = Bundle(for: FeedViewController.self)
        let storyboard = UIStoryboard(name: "Feed", bundle: bundle)
        let feedController = storyboard.instantiateInitialViewController() as! FeedViewController
        feedController.title = title
        feedController.delegate = delegate
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
