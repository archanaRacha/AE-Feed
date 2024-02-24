//
//  HTTPClient.swift
//  AE-Feed
//
//  Created by archana racha on 19/02/24.
//

import Foundation
public enum HTTPClientResult{
    case success(Data,HTTPURLResponse)
    case failure(Error)
}
public protocol HTTPClient{
    func get(from url: URL, completion:@escaping(HTTPClientResult)->Void)
}
