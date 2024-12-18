//
//  RemoteLoader.swift
//  AEFeedAPI
//
//  Created by archana racha on 18/12/24.
//

import Foundation
import AE_Feed

public final class RemoteLoader : FeedLoader{
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
                
                completion(RemoteLoader.map(data, from: response))
            case .failure:
                completion(.failure(RemoteLoader.Error.connectivity))
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


