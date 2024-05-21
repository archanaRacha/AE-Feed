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
    let calender = Calendar(identifier: .gregorian)
    public typealias saveResults = Error?
    public typealias LoadResult = LoadFeedResult
    private var maxCacheAgeInDays : Int {
        return 7
    }
    public init(store:FeedStore,currentDate : @escaping () -> Date){
        self.store = store
        self.currentDate = currentDate
    }
    public func save(_ items : [FeedImage],completion:@escaping(saveResults) -> Void){
        store.deleteCacheFeed {[weak self] error in
            guard let self = self else {return}
            if let cacheDeletionerror = error {
                completion(cacheDeletionerror)
            }else{
                self.cache(items,with:completion)
                
            }
            
        }
    }
    private func cache(_ items:[FeedImage],with completion:@escaping (saveResults) -> Void){
        store.insert(items,timestamp: currentDate()){ [weak self] error in
            guard self != nil else {return}
            completion(error)
        }
    }
    public func load(completion:@escaping(LoadResult) -> Void){
        store.retrieve { [weak self] retrieveCachedResult in
            guard let self = self else{return}
            switch retrieveCachedResult{
            case let .failure(error):
                self.store.deleteCacheFeed { _ in }
                completion(.failure(error))
                break
            case .found(feed: let feed, timestamp: let timestamp) where self.validate(timestamp):
                completion(.success(feed.toModels()))
                break
            case .found:
                self.store.deleteCacheFeed { _ in }
                completion(.success([]))
                break
            case .empty:
                completion(.success([]))
                break
            
            }
        }
    }
    public func validateCache(){
        store.retrieve { _ in }
        store.deleteCacheFeed { _ in }
    }
    private func validate(_ timestamp :Date) -> Bool{
        
        guard let maxCacheAge = calender.date(byAdding: .day , value:maxCacheAgeInDays,to:timestamp) else {
                return false
        }
        return currentDate() < maxCacheAge
        
    }
}

private extension Array where Element == FeedImage {
    func toLocal() -> [LocalFeedImage] {
        return map { LocalFeedImage(id : $0.id, description:$0.description, location:$0.location , url: $0.url)
        }
    }
}
private extension Array where Element == LocalFeedImage {
    func toModels() -> [FeedImage] {
        return map { FeedImage(id : $0.id, description:$0.description, location:$0.location , url: $0.url)
        }
    }
}


