//
//  HttpURLResponse+StatusCode.swift
//  AE-Feed
//
//  Created by archana racha on 05/10/24.
//

import Foundation

extension HTTPURLResponse {
    private static var OK_200: Int { return 200 }

    var isOK: Bool {
        return statusCode == HTTPURLResponse.OK_200
    }
}
