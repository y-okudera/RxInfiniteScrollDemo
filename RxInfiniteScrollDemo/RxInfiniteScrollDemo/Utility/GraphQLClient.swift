//
//  GraphQLClient.swift
//  RxInfiniteScrollDemo
//
//  Created by okudera on 2020/04/05.
//  Copyright © 2020 yuoku. All rights reserved.
//

import Apollo
import Foundation
import RxSwift
import RxApolloClient

struct GraphQLClient {

    private static var apolloClient: ApolloClient?

    static func fetch<T: GraphQLRequest>(graphQLRequest: T,
                                         cachePolicy: CachePolicy = .returnCacheDataElseFetch,
                                         queue: DispatchQueue = DispatchQueue.main) -> Observable<T.Query.Data> {
        let configuration = URLSessionConfiguration.default
        configuration.httpAdditionalHeaders = graphQLRequest.httpAdditionalHeaders
        let session = URLSession(configuration: configuration)
        let httpNetworkTransport = HTTPNetworkTransport(url: graphQLRequest.url, session: session)
        
        self.apolloClient = ApolloClient(networkTransport: httpNetworkTransport)
        return self.apolloClient!
            .rx
            .fetch(query: graphQLRequest.query, cachePolicy: cachePolicy, queue: queue)
            .asObservable()
    }
}
