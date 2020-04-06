//
//  LoadingCell.swift
//  RxInfiniteScrollDemo
//
//  Created by okudera on 2020/04/07.
//  Copyright © 2020 yuoku. All rights reserved.
//

import UIKit

final class LoadingCell: UITableViewCell {

    @IBOutlet private weak var activityIndicatorView: UIActivityIndicatorView! {
        didSet {
            if #available(iOS 13, *) {
                activityIndicatorView.style = .medium
            } else {
                activityIndicatorView.style = .gray
            }
        }
    }

    func startAnimating() {
        if activityIndicatorView.isAnimating {
            return
        }
        activityIndicatorView.startAnimating()
    }

    func stopAnimating() {
        if activityIndicatorView.isAnimating {
            activityIndicatorView.stopAnimating()
        }
    }
}

extension LoadingCell: TableViewNibRegistrable {}
