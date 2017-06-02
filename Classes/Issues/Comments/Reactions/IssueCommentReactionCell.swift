//
//  IssueCommentReactionCell.swift
//  Freetime
//
//  Created by Ryan Nystrom on 5/29/17.
//  Copyright © 2017 Ryan Nystrom. All rights reserved.
//

import UIKit
import SnapKit
import IGListKit

final class IssueCommentReactionCell: UICollectionViewCell,
IGListBindable,
UICollectionViewDataSource,
UICollectionViewDelegateFlowLayout {

    static let reuse = "cell"

    let addButton = UIButton()
    let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumInteritemSpacing = Styles.Sizes.columnSpacing / 2.0
        let view = UICollectionView(frame: .zero, collectionViewLayout: layout)
        view.register(IssueReactionCell.self, forCellWithReuseIdentifier: IssueCommentReactionCell.reuse)
        return view
    }()

    var reactions = [ReactionViewModel]()

    override init(frame: CGRect) {
        super.init(frame: frame)

        addButton.tintColor = Styles.Colors.Gray.light
        addButton.setTitle("+", for: .normal)
        addButton.setImage(UIImage(named: "smiley")?.withRenderingMode(.alwaysTemplate), for: .normal)
        addButton.addTarget(self, action: #selector(IssueCommentReactionCell.onAddButton), for: .touchUpInside)
        contentView.addSubview(addButton)
        addButton.snp.makeConstraints { make in
            make.left.equalTo(Styles.Sizes.gutter)
            make.centerY.equalTo(contentView)
        }

        collectionView.backgroundColor = .clear
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.isUserInteractionEnabled = false
        contentView.addSubview(collectionView)
        collectionView.snp.makeConstraints { make in
            make.left.equalTo(addButton.snp.right).offset(Styles.Sizes.columnSpacing)
            make.top.bottom.right.equalTo(contentView)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: Private API

    func onAddButton() {
        UIMenuController.shared.showReactions(fromView: addButton)
    }

    // MARK: IGListBindable

    func bindViewModel(_ viewModel: Any) {
        guard let viewModel = viewModel as? IssueCommentReactionViewModel else { return }
        reactions = viewModel.models
        collectionView.reloadData()
    }

    // MARK: UICollectionViewDataSource

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return reactions.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: IssueCommentReactionCell.reuse,
            for: indexPath
            ) as! IssueReactionCell
        let model = reactions[indexPath.item]
        cell.label.text = "\(model.type.rawValue) \(model.count)"
        cell.contentView.backgroundColor = model.viewerDidReact ? Styles.Colors.Blue.light : .clear
        return cell
    }

    // MARK: UICollectionViewDelegateFlowLayout

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
        ) -> CGSize {
        // lazy, simple width calculation
        let modifier: CGFloat
        switch reactions[indexPath.item].count {
        case 0..<10: modifier = 0
        case 10..<100: modifier = 1
        case 100..<1000: modifier = 2
            case 1000..<10000: modifier = 3
            case 100000..<1000000: modifier = 4
            default: modifier = 5
        }
        return CGSize(width: 20 + modifier * 5, height: collectionView.bounds.height)
    }

}