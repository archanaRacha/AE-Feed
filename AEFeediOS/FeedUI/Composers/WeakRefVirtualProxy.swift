//
//  WeakRefVirtualProxy.swift
//  AEFeediOS
//
//  Created by archana racha on 13/09/24.
//

import Foundation
import UIKit

final class WeakRefVirtualProxy<T:AnyObject> {
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
extension WeakRefVirtualProxy:FeedErrorView where T : FeedErrorView{
    func display(_ model: FeedErrorViewModel) {
        object?.display(model)
    }
}
