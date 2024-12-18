//
//  FeedItemMapper.swift
//  AE-Feed
//
//  Created by archana racha on 19/02/24.
//

import Foundation
import AE_Feed

public struct RemoteFeedItem: Decodable{
    let  id : UUID
    let description : String?
    let location:String?
    let image :URL
    var item : FeedImage {
        return FeedImage(id: id, description:description, location: location, url: image)
    }
}
internal final class FeedImageMapper{

    private struct Root : Decodable{
        let items :[RemoteFeedItem]
        var feed :[FeedImage] {
            return items.map { $0.item }
        }
    }
    
    internal static func  map(data:Data,from response : HTTPURLResponse) -> RemoteFeedLoader.Result {
        guard response.isOK, let root = try? JSONDecoder().decode(Root.self, from: data) else{

            return .failure(RemoteFeedLoader.Error.invalidData)
        }
        return .success(root.feed)
  
    }
}
