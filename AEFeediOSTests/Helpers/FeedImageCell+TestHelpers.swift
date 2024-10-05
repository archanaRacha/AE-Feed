//
//  FeedImageCell+TestHelpers.swift
//  AEFeediOSTests
//
//  Created by archana racha on 26/08/24.
//

import UIKit
import AEFeediOS

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
