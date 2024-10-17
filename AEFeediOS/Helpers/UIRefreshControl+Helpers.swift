//
//  UIRefreshControl+Helpers.swift
//  AE-Feed
//
//  Created by archana racha on 19/09/24.
//

import UIKit

extension UIRefreshControl{
    func update(isRefreshing:Bool){
        isRefreshing ? beginRefreshing() : endRefreshing()
    }
}
