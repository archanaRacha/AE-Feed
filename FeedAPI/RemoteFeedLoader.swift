//
//  RemoteFeedLoader.swift
//  AE-Feed
//
//  Created by archana racha on 12/02/24.
//

import Foundation

public final class RemoteFeedLoader{
    let client : HTTPClient
    let url : URL
    public enum Error: Swift.Error{
        case connectivity
        case invalidData
    }
    public enum Result: Equatable{
        case success([FeedItem])
        case failure(Error)
    }
    public init(client: HTTPClient, url: URL) {
        self.client = client
        self.url = url
    }
    public func load(completion:@escaping(Result) -> Void){
        client.get(from: url) { result in
            switch result{
            case  let .success(data,response):
                completion(self.map(data: data, from: response))
            case .failure:
                completion(.failure(.connectivity))
            }
        }
    }
    private func map(data:Data,from response : HTTPURLResponse) -> Result {
        do{
             let items = try FeedItemMapper.map(data, response)
            return .success(items)
           
        }catch{
            return .failure(.invalidData)
        }
    }
}


