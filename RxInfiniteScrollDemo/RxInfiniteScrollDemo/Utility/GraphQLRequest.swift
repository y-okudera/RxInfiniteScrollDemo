//
//  GraphQLRequest.swift
//  RxInfiniteScrollDemo
//
//  Created by okudera on 2020/04/05.
//  Copyright © 2020 yuoku. All rights reserved.
//

import Apollo
import Foundation

protocol GraphQLRequest {

    associatedtype Query: GraphQLQuery

    var query: Query { get }
    var url: URL { get }
    var httpAdditionalHeaders: [AnyHashable: Any]? { get }
}

extension GraphQLRequest {
    var httpAdditionalHeaders: [AnyHashable: Any]? {
        return [:]
    }
}
