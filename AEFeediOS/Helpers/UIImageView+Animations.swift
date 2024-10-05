//
//  UIImageView+Animations.swift
//  AEFeediOS
//
//  Created by archana racha on 12/09/24.
//

import Foundation
import UIKit

extension UIImageView {
    func setImageAnimated(_ newImage:UIImage?){
        image = newImage
        guard newImage != nil else {return}
        alpha = 0
        UIView.animate(withDuration: 0.25) {
            self.alpha = 1
        }

    }
}
