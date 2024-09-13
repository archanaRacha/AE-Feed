//
//  FeedViewAdapter.swift
//  AEFeediOS
//
//  Created by archana racha on 13/09/24.
//

import Foundation
import AE_Feed
import UIKit

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
