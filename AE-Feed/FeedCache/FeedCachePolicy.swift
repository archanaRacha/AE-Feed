//
//  FeedCachePolicy.swift
//  AE-Feed
//
//  Created by archana racha on 22/05/24.
//

import Foundation
internal final class FeedCachePolicy {
    private init() {}
    private static let calender = Calendar(identifier: .gregorian)
    
    private static var maxCacheAgeInDays : Int {
        return 7
    }
    static func validate(_ timestamp :Date, against date: Date) -> Bool{
        
        guard let maxCacheAge = calender.date(byAdding: .day , value:maxCacheAgeInDays,to:timestamp) else {
                return false
        }
        return date < maxCacheAge
        
    }
}
