//
//  UITableView+CellCastable.swift
//  RxInfiniteScrollDemo
//
//  Created by okudera on 2020/04/06.
//  Copyright © 2020 yuoku. All rights reserved.
//

import UIKit

extension UITableView {
    
    func dequeueReusableCell<T: UITableViewCell>(for indexPath: IndexPath) -> T {
        return dequeueReusableCell(withIdentifier: T.identifier, for: indexPath) as! T
    }
}
