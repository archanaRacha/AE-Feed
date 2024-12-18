//
//  RemoteLoader.swift
//  AEFeedAPI
//
//  Created by archana racha on 18/12/24.
//

import Foundation
import AE_Feed

public final class RemoteLoader<Resource>{
    private let client : HTTPClient
    private let url : URL
    private let mapper: Mapper
    public enum Error: Swift.Error{
        case connectivity
        case invalidData
    }
    public typealias Result = Swift.Result<Resource, Swift.Error>
    public typealias Mapper = (Data, HTTPURLResponse) throws -> Resource
    public init(url: URL, client: HTTPClient, mapper: @escaping Mapper) {
        self.client = client
        self.url = url
        self.mapper = mapper
    }
    
    public func load(completion:@escaping(Result) -> Void){
        client.get(from: url) {[weak self] result in
            guard let self = self else { return }
            switch result {
            case  let .success((data,response)):
                
                completion(self.map(data, from: response))
            case .failure:
                completion(.failure(Error.connectivity))
            }
        }
    }
    private func map(_ data: Data, from response: HTTPURLResponse) -> Result {
            do {
                let items = try FeedItemsMapper.map(data: data, from: response)
                return .success(try mapper(data, response))
            } catch {
                return .failure(error)
            }
        }
    
}


