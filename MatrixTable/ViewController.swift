//
//  ViewController.swift
//  MatrixTable
//
//  Created by Бучевский Андрей on 10.04.2024.
//

import UIKit

class ViewController: UIViewController {

    typealias DataSource = UITableViewDiffableDataSource<Section, Item>

    var items: [Item] = [] {
        didSet {
            reload()
        }
    }

    var selectedItemClosure: ((Item) -> Void)?

    var dataSource: DataSource?

    lazy var tableView: UITableView = {
        let tableView = UITableView(frame: view.bounds, style: .insetGrouped)
        tableView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: UITableViewCell.description())
        tableView.delegate = self
        return tableView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        view.addSubview(tableView)
        configureDataSource()

        var shuffledList: [Item] = []
        for i in 0...30 {
            shuffledList.append(Item(title: "\(i)", isSelected: false))
        }
        shuffledList.shuffle()
        items = shuffledList

        title = "Matrix Table"
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Shuffle", style: .plain, target: self, action: #selector(shuffleTapped))
    }

    private func configureDataSource() {
        dataSource = DataSource(tableView: tableView) { tableView, indexPath, item in
            let cell = tableView.dequeueReusableCell(withIdentifier: UITableViewCell.description(), for: indexPath)
            var content = cell.defaultContentConfiguration()
            content.text = item.title
            cell.contentConfiguration = content
            if item.isSelected {
                cell.accessoryType = .checkmark
            } else {
                cell.accessoryType = .none
            }
            return cell
        }
    }

    private func reload() {
        var snapshot = NSDiffableDataSourceSnapshot<Section, Item>()

        snapshot.appendSections([.numbers])
        snapshot.appendItems(items, toSection: .numbers)

        DispatchQueue.main.async { [weak self] in
            self?.dataSource?.apply(snapshot)
        }
    }

    @objc func shuffleTapped() {
        var shuffledList = items
        shuffledList.shuffle()
        items = shuffledList
    }
}

extension ViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        var currentItems = items
        var item = items[indexPath.row]
        currentItems.remove(at: indexPath.row)
        item.isSelected = true
        currentItems.insert(item, at: 0)
        items = currentItems
    }
}

enum Section: Hashable {
    case numbers
}

struct Item: Hashable {

    let title: String

    var isSelected: Bool
}
