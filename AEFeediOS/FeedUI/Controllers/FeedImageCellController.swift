//
//  FeedImageCellController.swift
//  AEFeediOS
//
//  Created by archana racha on 26/08/24.
//

import UIKit
import AE_Feed

protocol FeedImageCellControllerDelegate{
    func didRequestImage()
    func didCancelImageRequest()
}

final class FeedImageCellController : FeedImageView{
    private let delegate: FeedImageCellControllerDelegate
    private var cell : FeedImageCell?
    init(delegate: FeedImageCellControllerDelegate) {
        self.delegate = delegate
    }
      
    
    func view(in tableView:UITableView) -> UITableViewCell{
        self.cell = tableView.dequeueReuableCell()
        delegate.didRequestImage()
        return cell!
    }
    
    func preload() {
        delegate.didRequestImage()
    }

    func cancelLoad() {
        releaseCellForReuse()
        delegate.didCancelImageRequest()
    }
    func display(_ viewModel:FeedImageViewModel<UIImage>){
        cell?.locationContainer.isHidden = !viewModel.hasLocation
        cell?.locationLabel.text = viewModel.location
        cell?.descriptionLabel.text = viewModel.description
        cell?.feedImageView.setImageAnimated(viewModel.image)
        cell?.feedImageContainer.isShimmering = viewModel.isLoading
        cell?.feedImageRetryButton.isHidden = !viewModel.shouldRetry
        cell?.onRetry = delegate.didRequestImage
    }
    private func releaseCellForReuse(){
        cell = nil
    }
}


