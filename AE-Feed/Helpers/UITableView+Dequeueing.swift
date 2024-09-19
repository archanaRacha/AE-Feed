//
//  UITableView+Dequeueing.swift
//  AEFeediOS
//
//  Created by archana racha on 12/09/24.
//

import Foundation
import UIKit

extension UITableView{
    func dequeueReuableCell<T:UITableViewCell>() -> T {
        let identifier = String(describing: T.self)
        return dequeueReusableCell(withIdentifier: identifier) as! T
    }
}

