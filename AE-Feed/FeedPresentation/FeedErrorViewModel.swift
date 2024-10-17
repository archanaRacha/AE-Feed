//
//  FeedErrorViewModel.swift
//  AE-Feed
//
//  Created by archana racha on 20/09/24.
//

import Foundation

public struct FeedErrorViewModel{
    public let message: String?
    static var noError:FeedErrorViewModel{
        return FeedErrorViewModel(message: nil)
    }
    static func error(message:String) -> FeedErrorViewModel{
        return FeedErrorViewModel(message: message)
    }
}

