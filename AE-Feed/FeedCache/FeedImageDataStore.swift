//
//  FeedImageDataStore.swift
//  AE-Feed
//
//  Created by archana racha on 05/10/24.
//

import Foundation

public protocol FeedImageDataStore {
    typealias RetrievalResult = Swift.Result<Data?, Error>
    typealias InsertionResult = Swift.Result<Void, Error>

    func insert(_ data: Data, for url: URL, completion: @escaping (InsertionResult) -> Void)
    
    func retrieve(dataForURL url: URL, completion: @escaping (RetrievalResult) -> Void)
}