//
//  RemoteFeedLoader.swift
//  AE-Feed
//
//  Created by archana racha on 12/02/24.
//

import Foundation
import AE_Feed

public final class RemoteFeedLoader : FeedLoader{
    let client : HTTPClient
    let url : URL
    public enum Error: Swift.Error{
        case connectivity
        case invalidData
    }
    public typealias Result = FeedLoader.Result
    
    public init(client: HTTPClient, url: URL) {
        self.client = client
        self.url = url
    }
    public func load(completion:@escaping(Result) -> Void){
        client.get(from: url) {[weak self] result in
            guard  self != nil else {return}
            switch result {
            case  let .success((data,response)):
                
                completion(RemoteFeedLoader.map(data, from: response))
            case .failure:
                completion(.failure(RemoteFeedLoader.Error.connectivity))
            }
        }
    }
    private static func map(_ data: Data, from response: HTTPURLResponse) -> Result {
            do {
                let items = try FeedItemsMapper.map(data: data, from: response)
                return .success(items)
            } catch {
                return .failure(error)
            }
        }
    
}


