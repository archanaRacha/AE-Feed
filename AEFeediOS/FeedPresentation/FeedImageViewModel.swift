//
//  FeedImageViewModel.swift
//  AEFeediOS
//
//  Created by archana racha on 28/08/24.
//

import Foundation
import AE_Feed

struct FeedImageViewModel<Image>{
    let description:String?
    let location:String?
    let image:Image?
    let isLoading:Bool
    let shouldRetry:Bool
    
    var hasLocation:Bool{
        return location != nil
    }
}
