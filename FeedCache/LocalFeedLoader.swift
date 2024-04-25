//
//  LocalFeedLoader.swift
//  AE-Feed
//
//  Created by archana racha on 25/04/24.
//

import Foundation
public final class LocalFeedLoader{
    private let store: FeedStore
    private let currentDate: () -> Date
    public typealias saveResults = Error?
    public init(store:FeedStore,currentDate : @escaping () -> Date){
        self.store = store
        self.currentDate = currentDate
    }
    public func save(_ items : [FeedItem],completion:@escaping(saveResults) -> Void){
        store.deleteCacheFeed {[weak self] error in
            guard let self = self else {return}
            if let cacheDeletionerror = error {
                completion(cacheDeletionerror)
            }else{
                self.cache(items,with:completion)
                
            }
            
        }
    }
    private func cache(_ items:[FeedItem],with completion:@escaping (saveResults) -> Void){
        store.insert(items,timestamp: currentDate()){ [weak self] error in
            guard self != nil else {return}
            completion(error)
        }
    }
}

