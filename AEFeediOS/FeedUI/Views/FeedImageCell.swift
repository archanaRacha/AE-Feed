//
//  FeedImageCell.swift
//  AEFeediOSTests
//
//  Created by archana racha on 21/08/24.
//

import UIKit

class FeedImageCell: UITableViewCell {

    public let locationContainer = UIView()
    public let locationLabel = UILabel()
    public let descriptionLabel = UILabel()
    public let feedImageContainer = UIView()
    public let feedImageView = UIImageView()
    private(set) public lazy var feedImageRetryButton: UIButton = {
        let button = UIButton()
        button.addTarget(self, action: #selector(retryButtonTapped), for: .touchUpInside)
        return button
    }()

    var onRetry: (() -> Void)?

    @objc private func retryButtonTapped() {
        onRetry?()
    }
}
extension FeedImageCell {
    var isShowingLocation: Bool {
        return !locationContainer.isHidden
    }
    var isShowingImageLoadingIndicator: Bool {
        return feedImageContainer.isShimmering
    }
    var isShowingRetryAction: Bool {
            return !feedImageRetryButton.isHidden
        }
    func simulateRetryAction() {
        feedImageRetryButton.simulateTap()
    }

    var locationText : String? {
        return locationLabel.text
    }
    var descriptionText : String? {
        return descriptionLabel.text
    }
    var renderedImage: Data? {
        return feedImageView.image?.pngData()
    }
}
