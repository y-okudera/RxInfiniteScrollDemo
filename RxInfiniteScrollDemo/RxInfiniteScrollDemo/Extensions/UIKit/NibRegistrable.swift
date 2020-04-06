//
//  NibRegistrable.swift
//  RxInfiniteScrollDemo
//
//  Created by okudera on 2020/04/06.
//  Copyright © 2020 yuoku. All rights reserved.
//

import UIKit

protocol TableViewNibRegistrable where Self: UITableViewCell {

    /// TableViewにNibを登録する
    ///
    /// - Parameter tableView: 登録先のTableView
    static func register(tableView: UITableView)
}

extension TableViewNibRegistrable {

    static func register(tableView: UITableView) {
        let nib = UINib(nibName: identifier, bundle: Bundle(for: self))
        tableView.register(nib, forCellReuseIdentifier: identifier)
    }
}
