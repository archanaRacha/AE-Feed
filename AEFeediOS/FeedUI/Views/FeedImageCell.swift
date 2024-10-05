//
//  FeedImageCell.swift
//  AEFeediOSTests
//
//  Created by archana racha on 21/08/24.
//

import UIKit

class FeedImageCell: UITableViewCell {

    @IBOutlet private(set) public var locationContainer : UIView!
    @IBOutlet private(set) public var locationLabel : UILabel!
    @IBOutlet private(set) public var descriptionLabel : UILabel!
    @IBOutlet private(set) public var feedImageContainer : UIView!
    @IBOutlet private(set) public var feedImageView : UIImageView!
    @IBOutlet private(set) public var feedImageRetryButton: UIButton!
    var onRetry: (() -> Void)?

    @IBAction private func retryButtonTapped() {
        onRetry?()
    }
}
