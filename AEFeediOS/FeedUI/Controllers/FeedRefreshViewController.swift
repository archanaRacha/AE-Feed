//
//  FeedRefreshViewController.swift
//  AEFeediOS
//
//  Created by archana racha on 26/08/24.
//

import UIKit
import AE_Feed

protocol FeedRefreshViewControllerDelegate{
    func didRequestFeedRefresh()
}
final class FeedRefreshViewController : NSObject,FeedLoadingView {
    @IBOutlet var view : UIRefreshControl?
    var delegate: FeedRefreshViewControllerDelegate?
   
   
    @IBAction func refresh() {
        delegate?.didRequestFeedRefresh()
        
    }
    func display(_ viewModel: FeedLoadingViewModel) {
        if viewModel.isLoading{
            view?.beginRefreshing()
        }else{
            view?.endRefreshing()
        }
        
    }
}

