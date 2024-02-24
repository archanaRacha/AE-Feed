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
        var feed :[FeedItem] {
            return items.map { $0.item }
        }
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
    
    internal static func  map(data:Data,from response : HTTPURLResponse) -> RemoteFeedLoader.Result{
        guard response.statusCode == OK_200, let root = try? JSONDecoder().decode(Root.self, from: data) else{

            return .failure(.invalidData)
        }
        return .success(root.feed)
  
    }
}
