//
//  GitHubRequest.swift
//  RxInfiniteScrollDemo
//
//  Created by okudera on 2020/04/06.
//  Copyright © 2020 yuoku. All rights reserved.
//

import Apollo
import Foundation

struct GitHubRequest: GraphQLRequest {

    typealias Query = GitHubReposQuery

    var query: GitHubReposQuery
    var url: URL = "https://api.github.com/graphql".toURL()

    #warning("Set \"Bearer <Set GitHub personal access token>\"")
    var httpAdditionalHeaders: [AnyHashable: Any]? = ["Authorization": ""]
}
