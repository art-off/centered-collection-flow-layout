//
//  ViewController.swift
//  CenteredCollectionFlowLayoutExample
//
//  Created by Artem Rylov on 02.03.2025.
//

import UIKit
import CenteredCollectionFlowFayout

class ViewController: UIViewController, UICollectionViewDataSource {

    // Views
    private var collectionView: UICollectionView!

    // Dependencies
    let flowLayout = CenteredCollectionFlowLayout()

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Zoomed & snapped cells"

        flowLayout.delegate = self

        addCollectionView()
        addHelpersViews()
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 9
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath)
        cell.contentView.backgroundColor = indexPath.row % 2 == 0 ? .red : .yellow
        return cell
    }

    private func addCollectionView() {
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
        view.addSubview(collectionView)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 100),
            collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -100),
            collectionView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            collectionView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
        ])
        collectionView.layer.borderColor = UIColor.black.cgColor
        collectionView.layer.borderWidth = 2
        collectionView.dataSource = self
        collectionView.contentInsetAdjustmentBehavior = .always
        collectionView.register(CustomCollectionViewCell.self, forCellWithReuseIdentifier: "Cell")
    }

    private func addHelpersViews() {
        let leadingSquareView1 = UIView()
        leadingSquareView1.backgroundColor = .green
        leadingSquareView1.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(leadingSquareView1)
        NSLayoutConstraint.activate([
            leadingSquareView1.widthAnchor.constraint(equalToConstant: Self.offset),
            leadingSquareView1.heightAnchor.constraint(equalToConstant: Self.offset),
            leadingSquareView1.leadingAnchor.constraint(equalTo: collectionView.leadingAnchor),
            leadingSquareView1.topAnchor.constraint(equalTo: collectionView.bottomAnchor),
        ])

        let trailingSquareView1 = UIView()
        trailingSquareView1.backgroundColor = .green
        trailingSquareView1.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(trailingSquareView1)
        NSLayoutConstraint.activate([
            trailingSquareView1.widthAnchor.constraint(equalToConstant: Self.offset),
            trailingSquareView1.heightAnchor.constraint(equalToConstant: Self.offset),
            trailingSquareView1.trailingAnchor.constraint(equalTo: collectionView.trailingAnchor),
            trailingSquareView1.topAnchor.constraint(equalTo: collectionView.bottomAnchor),
        ])

        let centerLineView = UIView()
        centerLineView.backgroundColor = .green
        centerLineView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(centerLineView)
        NSLayoutConstraint.activate([
            centerLineView.topAnchor.constraint(equalTo: collectionView.topAnchor),
            centerLineView.bottomAnchor.constraint(equalTo: collectionView.bottomAnchor),
            centerLineView.centerXAnchor.constraint(equalTo: collectionView.centerXAnchor),
            centerLineView.widthAnchor.constraint(equalToConstant: 3),
        ])
    }
}

extension ViewController: CenteredCollectionFlowLayoutDelegate {

    static let offset: CGFloat = 30

    static let sizes: [CGSize] = [
        CGSize(width: 100, height: 100),
        CGSize(width: 250, height: 200),
        CGSize(width: 200, height: 300),
        CGSize(width: 50, height: 200),
        CGSize(width: 200, height: 300),
        CGSize(width: 20, height: 150),
        CGSize(width: 50, height: 100),
        CGSize(width: 50, height: 100),
        CGSize(width: 50, height: 100),
    ]

    func centeredCollecitonFlowLayout(sizeFor indexPath: IndexPath) -> CGSize {
        Self.sizes[indexPath.item]
    }

    func centeredCollectionFlowLayoutOffsetConstant() -> CGFloat {
        Self.offset
    }
}

class CustomCollectionViewCell: UICollectionViewCell {

    private let label = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)

        label.numberOfLines = 0
        contentView.addSubview(label)
        label.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: contentView.topAnchor),
            label.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            label.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            label.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
