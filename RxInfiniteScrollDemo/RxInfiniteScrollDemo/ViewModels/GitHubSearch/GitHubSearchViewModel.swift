//
//  GitHubSearchViewModel.swift
//  RxInfiniteScrollDemo
//
//  Created by okudera on 2020/04/06.
//  Copyright © 2020 yuoku. All rights reserved.
//

import Action
import Foundation
import RxCocoa
import RxSwift
import Unio

protocol GitHubSearchViewModelType : AnyObject {
    var input: Unio.InputWrapper<GitHubSearchViewModel.Input> { get }
    var output: Unio.OutputWrapper<GitHubSearchViewModel.Output> { get }
}

final class GitHubSearchViewModel: UnioStream<GitHubSearchViewModel>, GitHubSearchViewModelType {

    init() {
        super.init(input: Input(), state: State(), extra: Extra())
    }
}

extension GitHubSearchViewModel {

    typealias Extra = NoExtra
    
    struct Input: InputType {
        let initialFetchTrigger = PublishRelay<String>()
        let fetchTrigger = PublishRelay<Void>()
    }

    struct Output: OutputType {
        let searchText: BehaviorRelay<String>
        let nodes: BehaviorRelay<[GitHubRequest.Query.Data.Search.Node]>
        let fetchError: Observable<Error>
        let isLoading: BehaviorRelay<Bool>
    }

    struct State: StateType {
        let searchText = BehaviorRelay<String>(value: "")
        let nodes = BehaviorRelay<[GitHubRequest.Query.Data.Search.Node]>(value: [])
        var pageInfo = BehaviorRelay<GitHubRequest.Query.Data.Search.PageInfo>(value: .init(hasPreviousPage: false, hasNextPage: true))
        let isLoading = BehaviorRelay<Bool>(value: false)

        mutating func initState() {
            self.searchText.accept("")
            self.nodes.accept([])
            self.pageInfo.accept(.init(hasPreviousPage: false, hasNextPage: true))
            self.isLoading.accept(false)
        }
    }
}

extension GitHubSearchViewModel {
    
    static func bind(from dependency: Dependency<GitHubSearchViewModel.Input, GitHubSearchViewModel.State, GitHubSearchViewModel.Extra>,
                     disposeBag: DisposeBag) -> GitHubSearchViewModel.Output {
        
        let input = dependency.inputObservables
        var state = dependency.state
        
        let fetchData = Action<GitHubRequest, GitHubRequest.Query.Data> { args in
            GraphQLClient.fetch(graphQLRequest: args)
        }
        
        fetchData.elements
            .bind(onNext: { data in
                if let optionalNodes = data.search.nodes {
                    let nodes = optionalNodes.compactMap { $0 }
                    state.nodes.accept(state.nodes.value + nodes)
                } else {
                    state.nodes.accept([])
                }
                state.pageInfo.accept(data.search.pageInfo)
            })
            .disposed(by: disposeBag)

        // 初回検索(画面表示時・検索ワード変更時)
        input.initialFetchTrigger
            .bind(onNext: { text in
                state.initState()
                print("★初期startCursor", state.pageInfo.value.startCursor ?? "nil")
                print("★初期endCursor", state.pageInfo.value.endCursor ?? "nil")

                state.searchText.accept(text)
                state.nodes.accept([])
                let query = GitHubReposQuery(query: text, type: .repository, first: 20, after: state.pageInfo.value.endCursor)
                let request = GitHubRequest(query: query)
                fetchData.execute(request)
            })
            .disposed(by: disposeBag)

        // 追加読み込み
        input.fetchTrigger
            .filter { _ in state.pageInfo.value.hasNextPage }
            .bind(onNext: { _ in
                print("★startCursor", state.pageInfo.value.startCursor ?? "nil")
                print("★endCursor", state.pageInfo.value.endCursor ?? "nil")

                let query = GitHubReposQuery(query: state.searchText.value, type: .repository, first: 20, after: state.pageInfo.value.endCursor)
                let request = GitHubRequest(query: query)
                fetchData.execute(request)
            })
            .disposed(by: disposeBag)

        fetchData.executing
            .bind(to: state.isLoading)
            .disposed(by: disposeBag)
        
        return GitHubSearchViewModel.Output(
            searchText: state.searchText,
            nodes: state.nodes,
            fetchError: fetchData.errors.map { $0 as Error },
            isLoading: state.isLoading
        )
    }
}
