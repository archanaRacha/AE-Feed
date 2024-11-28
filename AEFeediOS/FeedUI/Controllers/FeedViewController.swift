//
//  FeedViewController.swift
//  
//
//  Created by archana racha on 19/07/24.
//

import UIKit
import AE_Feed

protocol FeedViewControllerDelegate{
    func didRequestFeedRefresh()
}

public final class FeedViewController : UITableViewController,UITableViewDataSourcePrefetching,FeedLoadingView,FeedErrorView {
    var delegate: FeedViewControllerDelegate?
    @IBOutlet private(set) public var errorView : ErrorView?
    var tableModel = [FeedImageCellController]() {
        didSet { self.tableView.reloadData()}
    }
    private var tasks = [IndexPath : FeedImageDataLoaderTask]()
   
    public override func viewDidLoad() {
        super.viewDidLoad()
        refresh()
    }
    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        tableView.sizeTableHeaderToFit()
    }
    @IBAction private func refresh() {
        delegate?.didRequestFeedRefresh()
        
    }
    public func display(_ cellControllers: [FeedImageCellController]){
        let _ = cellControllers.enumerated().map { index, new_cellController in
            tableModel.append(new_cellController)
          let  _ = cellController(forRowAt:IndexPath(row: index, section: 0))
        }
    }
    public func display(_ viewModel: FeedLoadingViewModel) {
        refreshControl?.update(isRefreshing: viewModel.isLoading)
    }
    public func display(_ viewModel:FeedErrorViewModel){
        errorView?.message = viewModel.message
    }
    public override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableModel.count
    }
    public override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return cellController(forRowAt: indexPath).view(in: tableView)
    }
    public override func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cancelCellControllerLoad(forRowAt: indexPath)
    }
    public func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        indexPaths.forEach { indexPath in
            cellController(forRowAt: indexPath).preload()
        }
    }
    public func tableView(_ tableView: UITableView, cancelPrefetchingForRowsAt indexPaths: [IndexPath]) {
        indexPaths.forEach(cancelCellControllerLoad)
    }

    private func cellController(forRowAt indexPath: IndexPath) -> FeedImageCellController {
        return tableModel[indexPath.row]
    }
    private func cancelCellControllerLoad(forRowAt indexPath: IndexPath) {
        cellController(forRowAt: indexPath).cancelLoad()
    }
}
