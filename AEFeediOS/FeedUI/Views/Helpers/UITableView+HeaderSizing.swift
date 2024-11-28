//
//  UITableView+HeaderSizing.swift
//  AEFeediOS
//
//  Created by archana racha on 28/11/24.
//

import UIKit

extension UITableView {
    public func sizeTableHeaderToFit() {
        guard let header = tableHeaderView else { return }

        let size = header.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)

        let needsFrameUpdate = header.frame.height != size.height
        if needsFrameUpdate {
            header.frame.size.height = size.height
            tableHeaderView = header
        }
    }
}
