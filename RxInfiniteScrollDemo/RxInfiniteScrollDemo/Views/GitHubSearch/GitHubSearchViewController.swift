//
//  GitHubSearchViewController.swift
//  RxInfiniteScrollDemo
//
//  Created by okudera on 2020/04/06.
//  Copyright © 2020 yuoku. All rights reserved.
//

import RxCocoa
import RxSwift
import RxViewController
import UIKit

final class GitHubSearchViewController: UIViewController {

    // MARK: - IBOutlet

    @IBOutlet private weak var tableView: UITableView! {
        didSet {
            tableView.delegate = self
            tableView.dataSource = self
        }
    }

    // MARK: - Properties

    private let initWord = "Swift"

    // TODO: DI
    var viewModel: GitHubSearchViewModel! = .init()

    private var disposeBag = DisposeBag()
    private var searchBar: UISearchBar?

    private lazy var searchController: UISearchController! = {
        return UISearchController(searchResultsController: nil)
    }()

    // MARK: - Life cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
}

// MARK: - Private methods
extension GitHubSearchViewController {

    private func setup() {
        registerNibs()
        setupNavigationItem(inputWord: initWord)
        bindInput()
        bindOutput()
    }

    private func registerNibs() {
        GitHubRepositoryCell.register(tableView: self.tableView)
        LoadingCell.register(tableView: self.tableView)
    }

    private func setupNavigationItem(inputWord: String) {
        if #available(iOS 11.0, *) {
            self.searchBar = searchController.searchBar
            searchController.obscuresBackgroundDuringPresentation = false
            navigationItem.searchController = searchController
            navigationItem.hidesSearchBarWhenScrolling = false
        } else {
            self.searchBar = UISearchBar()
            self.searchBar?.sizeToFit()
            navigationItem.titleView = self.searchBar
        }
        self.searchBar?.delegate = self
        self.searchBar?.showsCancelButton = false
        self.searchBar?.returnKeyType = .search
        self.searchBar?.text = inputWord
        navigationItem.title = inputWord
    }

    private func bindInput() {

        // 初期検索(画面表示時)
        self.rx.viewWillAppear
            .take(1) // 無限スクロールで取得した内容が破棄されると困るので、初回のみフェッチ
            .map { [weak self] _ in
                guard let `self` = self else { return "" }
                return self.initWord
        }
            .bind(to: self.viewModel.input.initialFetchTrigger)
            .disposed(by: self.disposeBag)

        // インクリメンタルサーチ
        self.searchBar?
            .rx
            .text
            .filter { [weak self] _ in
                guard let `self` = self else { return false }

                let willSearchText = self.searchBar?.text ?? ""
                if willSearchText.isEmpty { return true }
                let searchedText = self.viewModel.output.searchText.value

                // 同じテキストの場合は、無限スクロールで取得した内容が破棄されると困るので、検索しない
                if willSearchText == searchedText {
                    return false
                }
                return true
        }
            .debounce(.milliseconds(500), scheduler: MainScheduler.instance)
            .compactMap{ $0 }
            .bind(to: self.viewModel.input.initialFetchTrigger)
            .disposed(by: self.disposeBag)

        // 追加読み込み
        self.tableView
            .rx
            .didScroll
            .filter { [weak self] _ in
                guard let `self` = self else { return false }
                // スクロールビューの末尾に近づいて、且つロード中じゃなければ追加読み込みする
                return self.tableView.isNearBottomEdge() && !self.viewModel.output.isLoading.value
        }
            .bind(to: self.viewModel.input.fetchTrigger)
            .disposed(by: self.disposeBag)
    }

    private func bindOutput() {

        self.viewModel.output.searchText
            .bind(onNext: { [weak self] searchText in
                self?.searchBar?.text = searchText
                self?.navigationItem.title = searchText
            })
            .disposed(by: self.disposeBag)

        self.viewModel.output.nodes
            .bind(onNext: { [weak self] nodes in
                self?.tableView.reloadData()
            })
            .disposed(by: self.disposeBag)

        self.viewModel.output.fetchError
            .bind(onNext: { [weak self] error in
                print("⭐️error", error)
                // TODO: Error handling
            })
            .disposed(by: self.disposeBag)
    }
}

// MARK: - UISearchBarDelegate
extension GitHubSearchViewController: UISearchBarDelegate {

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        navigationItem.title = searchBar.text
    }
}

// MARK: - UITableViewDataSource
extension GitHubSearchViewController: UITableViewDataSource {

    // TODO: - refactoring

    func numberOfSections(in tableView: UITableView) -> Int {
        let isLoading = self.viewModel.output.isLoading.value
        return isLoading ? 2 : 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            let nodesCount = self.viewModel.output.nodes.value.count
            return nodesCount

        case 1:
            return 1

        default:
            return 0
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            return self.gitHubRepositoryCell(tableView: tableView, cellForRowAt: indexPath)

        case 1:
            return self.loadingCell(tableView: tableView, cellForRowAt: indexPath)

        default:
            return UITableViewCell()
        }
    }

    private func gitHubRepositoryCell(tableView: UITableView, cellForRowAt indexPath: IndexPath) -> GitHubRepositoryCell {
        let cell: GitHubRepositoryCell = tableView.dequeueReusableCell(for: indexPath)

        let nodes = self.viewModel.output.nodes.value
        if let repository = nodes[indexPath.row].asRepository {
            cell.configure(githubRepository: repository)
        }
        return cell
    }

    private func loadingCell(tableView: UITableView, cellForRowAt indexPath: IndexPath) -> LoadingCell {
        let cell: LoadingCell = tableView.dequeueReusableCell(for: indexPath)

        cell.startAnimating()
        return cell
    }
}

// MARK: - UITableViewDelegate
extension GitHubSearchViewController: UITableViewDelegate {}
