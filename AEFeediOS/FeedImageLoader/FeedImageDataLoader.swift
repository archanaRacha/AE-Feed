//
//  FeedImageDataLoader.swift
//  AEFeediOS
//
//  Created by archana racha on 26/08/24.
//

import Foundation

public protocol FeedImageDataLoaderTask{
    func cancel()
}
public protocol FeedImageDataLoader {
    typealias Result = Swift.Result<Data,Error>
    func loadImageData(from url:URL,completion:@escaping((Result) -> Void))-> FeedImageDataLoaderTask
}
