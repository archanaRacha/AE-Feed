//
//  FeedCacheTestHelpers.swift
//  AE-FeedTests
//
//  Created by archana racha on 21/05/24.
//

import Foundation
import AE_Feed

func uniqueImage() -> FeedImage {
    return FeedImage(id: UUID(), description: "any", location: "any", url: anyURL())
}
func uniqueImageFeed() -> (models: [FeedImage], local: [LocalFeedImage]) {
    let models = [uniqueImage(), uniqueImage()]
    let local = models.map { LocalFeedImage(id: $0.id, description: $0.description, location: $0.location, url: $0.url) }
    return (models, local)
}
extension Date {
    func adding(days:Int) -> Date{
        return Calendar(identifier: .gregorian).date(byAdding: .day, value: days, to: self)!
    }
    func adding(seconds:Int) -> Date{
        return Calendar(identifier: .gregorian).date(byAdding: .second, value: seconds, to: self)!
    }
}

