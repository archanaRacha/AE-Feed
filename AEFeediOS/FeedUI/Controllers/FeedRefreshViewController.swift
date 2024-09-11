//
//  FeedRefreshViewController.swift
//  AEFeediOS
//
//  Created by archana racha on 26/08/24.
//

import UIKit
import AE_Feed


final class FeedRefreshViewController : NSObject,FeedLoadingView {
    private(set) lazy var view = loadView()

    private let loadFeed : () -> Void
    init(loadFeed:@escaping () -> Void) {
        self.loadFeed = loadFeed
    }
    @objc func refresh() {
        loadFeed()
        
    }
    func display(_ viewModel: FeedLoadingViewModel) {
        if viewModel.isLoading{
            view.beginRefreshing()
        }else{
            view.endRefreshing()
        }
        
    }
    private func loadView() -> UIRefreshControl{
        let view = UIRefreshControl()
        view.addTarget(self, action: #selector(refresh), for: .valueChanged)
        return view
    }
}

