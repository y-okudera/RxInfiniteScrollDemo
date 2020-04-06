//
//  String+ToURL.swift
//  RxInfiniteScrollDemo
//
//  Created by okudera on 2020/04/04.
//  Copyright © 2020 yuoku. All rights reserved.
//

import Foundation

extension String {
    func toURL() -> URL {
        guard let url = URL(string: self) else {
            fatalError("URL failed to instantiate from string.")
        }
        return url
    }
}
