//
//  GitHubRepositoryCell.swift
//  RxInfiniteScrollDemo
//
//  Created by okudera on 2020/04/06.
//  Copyright © 2020 yuoku. All rights reserved.
//

import UIKit
import RxNuke
import RxSwift
import Nuke

final class GitHubRepositoryCell: UITableViewCell {

    @IBOutlet private weak var nameWithOwnerLabel: UILabel!
    @IBOutlet private weak var avatarImageView: UIImageView!
    @IBOutlet private weak var descriptionLabel: UILabel!
    @IBOutlet private weak var primaryLanguageLabel: UILabel!

    private var disposeBag = DisposeBag()

    override func prepareForReuse() {
        super.prepareForReuse()
        avatarImageView.image = nil
    }
}

extension GitHubRepositoryCell {

    /// セルの表示情報を設定する
    func configure(githubRepository: GitHubRequest.Query.Data.Search.Node.AsRepository) {
        nameWithOwnerLabel.text = githubRepository.nameWithOwner

        ImagePipeline.shared.rx.loadImage(with: githubRepository.owner.avatarUrl.toURL())
            .subscribe(onSuccess: { [weak self] in
                self?.avatarImageView.image = $0.image
            })
            .disposed(by: disposeBag)

        descriptionLabel.text = githubRepository.description
        primaryLanguageLabel.text = githubRepository.primaryLanguage?.name
    }
}

extension GitHubRepositoryCell: TableViewNibRegistrable {}
