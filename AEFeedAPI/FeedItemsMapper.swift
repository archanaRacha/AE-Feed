//
//  FeedItemMapper.swift
//  AE-Feed
//
//  Created by archana racha on 19/02/24.
//

import Foundation
import AE_Feed


public final class FeedItemsMapper {

    
    private struct Root : Decodable{
        private let items :[RemoteFeedItem]
        
        private struct RemoteFeedItem: Decodable{
            let  id : UUID
            let description : String?
            let location:String?
            let image :URL
        }
        var images: [FeedImage] {
            items.map { FeedImage(id: $0.id, description: $0.description, location: $0.location, url: $0.image) }
        }
    }
    public static func  map(data:Data,from response : HTTPURLResponse) throws -> [FeedImage] {
        guard response.isOK, let root = try? JSONDecoder().decode(Root.self, from: data) else{

            throw RemoteFeedLoader.Error.invalidData
        }
        return root.images
  
    }
}

