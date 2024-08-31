//
//  FeedImageViewModel.swift
//  AEFeediOS
//
//  Created by archana racha on 28/08/24.
//

import Foundation
import AE_Feed
import UIKit

final class FeedImageViewModel {
    private var task: FeedImageDataLoaderTask?
    private let model: FeedImage
    private let imageLoader: FeedImageDataLoader
    
    init(task: FeedImageDataLoaderTask? = nil, model: FeedImage, imageLoader: FeedImageDataLoader) {
        self.task = task
        self.model = model
        self.imageLoader = imageLoader
    }
    var description : String?{
        return model.description
    }
    var location:String?{
        return model.location
    }
    var hasLocation:Bool{
        return location != nil
    }
    var onImageLoad:((UIImage) -> Void)?
    var onImageLoadingStateChange:((Bool)->Void)?
    var onShouldRetryImageLoadStateChange:((Bool)->Void)?
    
    func loadImageData() {
        onImageLoadingStateChange?(true)
        onShouldRetryImageLoadStateChange?(false)
        task = imageLoader.loadImageData(from:model.url, completion: { [weak self] result in
            self?.handle(result)
        })
    }
    
    private func handle(_ result : FeedImageDataLoader.Result){
        if let image = (try? result.get()).flatMap(UIImage.init){
            onImageLoad?(image)
        }else{
            onShouldRetryImageLoadStateChange?(true)
        }
        onImageLoadingStateChange?(false)
    }
    func cancelImageDataLoad(){
        task?.cancel()
        task = nil
    }
}
