//
//  RemoteFeedLoader.swift
//  AE-Feed
//
//  Created by archana racha on 12/02/24.
//

import Foundation
public protocol HTTPClient{
    func get(from url: URL, completion:@escaping(Error)->Void)
}
public final class RemoteFeedLoader{
    let client : HTTPClient
    let url : URL
    public enum Error: Swift.Error{
        case connectivity
    }
    public init(client: HTTPClient, url: URL) {
        self.client = client
        self.url = url
    }
    public func load(completion:@escaping(RemoteFeedLoader.Error) -> Void){
        client.get(from: url) { error in
            completion(.connectivity)
        }
    }
}
