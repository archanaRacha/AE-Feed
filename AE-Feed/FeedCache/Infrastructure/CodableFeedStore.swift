//
//  CodableFeedStore.swift
//  AE-Feed
//
//  Created by archana racha on 25/05/24.
//

import Foundation

public class CodableFeedStore : FeedStore{
  
    private struct Cache : Codable {
        let feed :[CodableFeedImage]
        let timestamp: Date
        var localFeed: [LocalFeedImage]{
            return feed.map{$0.local}
        }
    }
    private struct CodableFeedImage: Equatable, Codable {
        private let id: UUID
        private let description: String?
        private let location: String?
        private let url: URL
        
        public init(image:LocalFeedImage) {
            self.id = image.id
            self.description = image.description
            self.location = image.location
            self.url = image.url
        }
        var local : LocalFeedImage {
            return LocalFeedImage(id: id, description: description, location: location, url: url)
        }
    }
    private let queue = DispatchQueue(label: "\(CodableFeedStore.self)Queue",qos: .userInitiated, attributes: .concurrent)
    private let storeURL : URL
    public init(storeURL: URL) {
        self.storeURL = storeURL
    }
    public func retrieve(completion:@escaping RetrievalCompletions) {
        let storeURL = self.storeURL
        queue.async {
            guard let data = try? Data(contentsOf: storeURL) else {return completion(.success(.none))}
            do{
                let decoder = JSONDecoder()
                let cache = try decoder.decode(Cache.self, from: data)
                completion(.success(CachedFeed(feed: cache.localFeed, timestamp: cache.timestamp)))
            }catch{
                completion(.failure(error))
            }
        }
    }
    
    public func insert(_ feed : [LocalFeedImage],timestamp: Date,completion:@escaping InsertionCompletions ){
        let storeURL = self.storeURL
        queue.async(flags: .barrier) {
            do {
                let encoder = JSONEncoder()
                let encoded = try encoder.encode(Cache(feed:feed.map(CodableFeedImage.init),timestamp:timestamp))
                try encoded.write(to: storeURL)
                completion(.success(()))
            }catch{
                completion(.failure(error))
            }
        }
    }
    public func deleteCachedFeed(completion: @escaping DeletionCompletion) {
        let storeURL = self.storeURL
        queue.async(flags: .barrier) {
            guard FileManager.default.fileExists(atPath: storeURL.path) else{
                return completion(.success(()))
            }
            do{
                try FileManager.default.removeItem(at: storeURL)
                completion(.success(()))
            }catch{
                completion(.failure(error))
            }
        }
    }
}
