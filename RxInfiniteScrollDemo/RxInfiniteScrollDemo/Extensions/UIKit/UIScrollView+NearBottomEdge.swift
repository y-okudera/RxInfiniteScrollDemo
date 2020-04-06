//
//  UIScrollView+NearBottomEdge.swift
//  RxInfiniteScrollDemo
//
//  Created by okudera on 2020/04/06.
//  Copyright © 2020 yuoku. All rights reserved.
//

import UIKit

extension UIScrollView {
    func isNearBottomEdge(edgeOffset: CGFloat = 20.0) -> Bool {
        if contentSize.height <= 0 {
            return false
        }
        return contentOffset.y + frame.size.height + edgeOffset > contentSize.height
    }
}
