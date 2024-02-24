//
//  FeedItemMapper.swift
//  AE-Feed
//
//  Created by archana racha on 19/02/24.
//

import Foundation

internal final class FeedItemMapper{
    private static var OK_200 : Int {return 200}
    private struct Root : Decodable{
        let items :[Item]
    }
    private struct Item: Decodable{
        let  id : UUID
        let description : String?
        let location:String?
        let image :URL
        var item : FeedItem {
            return FeedItem(id: id, description:description, location: location, imageURL: image)
        }
    }
    static func map(_ data:Data, _ response: HTTPURLResponse)throws -> [FeedItem]{
        guard response.statusCode == OK_200 else{
            throw RemoteFeedLoader.Error.invalidData
        }
        let root = try JSONDecoder().decode(Root.self, from: data)
        return root.items.map{$0.item}
    }
}
