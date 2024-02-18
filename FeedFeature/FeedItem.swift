//
//  FeedItem.swift
//  AE-Feed
//
//  Created by archana racha on 09/02/24.
//

import Foundation

public struct FeedItem: Equatable{
    let id: UUID
    let description : String?
    let location:String?
    let imageURL : URL
}
