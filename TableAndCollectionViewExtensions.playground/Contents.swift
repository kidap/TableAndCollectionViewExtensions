import UIKit



protocol ReuseIdentifiable {
    static var reuseID: String { get }
}

extension ReuseIdentifiable {
    static var reuseID: String { return String(describing: self) }
}

protocol NibLoadable: class {
    static var nib: UINib { get }
}

extension NibLoadable where Self: ReuseIdentifiable {
    static var nib: UINib { return UINib(nibName: reuseID, bundle: Bundle(for: Self.self)) }
}

extension UITableView {
    func register<T: NibLoadable & ReuseIdentifiable>(_ cellClass: T.Type) {
        register(cellClass.nib, forCellReuseIdentifier: cellClass.reuseID)
    }

    func dequeue<T: ReuseIdentifiable>(_ cellClass: T.Type, indexPath: IndexPath) -> T {
        return dequeueReusableCell(withIdentifier: cellClass.reuseID, for: indexPath) as! T
    }
}

extension UICollectionView {
    func register<T: NibLoadable & ReuseIdentifiable>(_ cellClass: T.Type) {
        register(cellClass.nib, forCellWithReuseIdentifier: cellClass.reuseID)
    }

    func dequeue<T: ReuseIdentifiable>(_ cellClass: T.Type, indexPath: IndexPath) -> T {
        return dequeueReusableCell(withReuseIdentifier: cellClass.reuseID, for: indexPath) as! T
    }
}


class TableViewCell: UITableViewCell, NibLoadable, ReuseIdentifiable {}
class CollectionViewCell: UICollectionViewCell, NibLoadable, ReuseIdentifiable {}


let tableView = UITableView(frame: .zero, style: .plain)
let layout = UICollectionViewLayout()
let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)

let indexPath = IndexPath(row: 0, section: 0)
let cvCell = tableView.dequeue(TableViewCell.self, indexPath: indexPath)
let tvCell = collectionView.dequeue(CollectionViewCell.self, indexPath: indexPath)
