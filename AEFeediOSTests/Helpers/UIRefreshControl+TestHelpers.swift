//
//  UIRefreshControl+TestHelpers.swift
//  AEFeediOSTests
//
//  Created by archana racha on 26/08/24.
//

import UIKit

extension UIRefreshControl{
    func simulatePullToRefresh() {
        simulate(event: .valueChanged)
    }
    
}
