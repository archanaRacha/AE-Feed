//
//  FeedErrorViewModel.swift
//  AEFeediOS
//
//  Created by archana racha on 19/09/24.
//

import Foundation

struct FeedErrorViewModel{
    let message: String?
    static var noError:FeedErrorViewModel{
        return FeedErrorViewModel(message: nil)
    }
    static func error(message:String) -> FeedErrorViewModel{
        return FeedErrorViewModel(message: message)
    }
}
