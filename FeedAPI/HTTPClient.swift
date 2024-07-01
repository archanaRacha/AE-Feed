//
//  HTTPClient.swift
//  AE-Feed
//
//  Created by archana racha on 19/02/24.
//

import Foundation

public protocol HTTPClient{
    typealias Result = Swift.Result<(Data,HTTPURLResponse),Error>
    ///The completion handler can be invoked in any thread.
    /// Clients are responsible to dispatch to appropriate threads, if needed.
    func get(from url: URL, completion:@escaping(Result)->Void)
}
