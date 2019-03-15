# Improving Table View and Collection View APIs


## TLDR
### 1. Registering cells 
```
tableView.register(UINib(nibName: "TableViewCell",
                   bundle: Bundle(for: type(of: self))), forCellReuseIdentifier: "TableViewCell")
```
vs 
```
tableView.register(TableViewCell.self)
```

### 2. Dequeueing cells
```
tableView.dequeueReusableCell(withIdentifier: "TableViewCell", for: indexPath)
```
vs
```
tableView.dequeue(TableViewCell.self, indexPath: indexPath)
```


## Protocols
### 1. ReuseIdentifiable 
#### Implementation
- **reuseID** - returns the name of the class
```
protocol ReuseIdentifiable {
    static var reuseID: String { get }
}

extension ReuseIdentifiable {
    static var reuseID: String { return String(describing: self) }
}
```

#### Usage
```
class TableViewCell: UITableViewCell, ReuseIdentifiable {}
class CollectionViewCell: UICollectionViewCell, ReuseIdentifiable {}
```

### 2. NibLoadable 
#### Implementation
- **nib** - returns a `UINib` using the `reuseID` and the bundle of the class
```
  protocol NibLoadable: class {
      static var nib: UINib { get }
  }

  extension NibLoadable where Self: ReuseIdentifiable {
      static var nib: UINib {
          return UINib(nibName: reuseID, bundle: Bundle(for: Self.self))
      }
  }
```

#### Usage
```
  class TableViewCell: UITableViewCell, NibLoadable, ReuseIdentifiable {}
  class CollectionViewCell: UICollectionViewCell, NibLoadable, ReuseIdentifiable {}
```


## Safer Table View and Collection View


### 1. Registering cells 
#### Implementation
##### 🍎's API
To register a nib, we normally pass string literals for the nib name and reuseIdentifier.
```
  tableView.register(UINib(nibName: "TableViewCell",
                     bundle: Bundle(for: type(of: self))),
                     forCellReuseIdentifier: "TableViewCell")
```


##### Cleaner way

Create a convenience method that takes in a cell that adopts both `NibLoadable` & `ReuseIdentifiable`. We can then use the `nib` and `reuseID` properties to register the cell
```
  func register<T: NibLoadable & ReuseIdentifiable>(_ cellClass: T.Type) {
    register(cellClass.nib, forCellReuseIdentifier: cellClass.reuseID)
  }
```

#### Usage
```
  tableView.register(TableViewCell.self)
```

### 2. Dequeueing cells
#### Implementation
##### 🍎's API
To dequeue a cell, we need to pass in the cell's reuse identifier. Again, we would normal just pass in a string literal
```
  tableView.dequeueReusableCell(withIdentifier: "TableViewCell", for: indexPath)
```

#### Cleaner way
Create a convenience method that takes in a cell that adopts `ReuseIdentifiable`. We then use the `reuseID` property when dequeueing a cell
```
  func dequeue<T: ReuseIdentifiable>(_ cellClass: T.Type, indexPath: IndexPath) -> T {
    return dequeueReusableCell(withIdentifier: cellClass.reuseID, for: indexPath) as! T
  }
```

#### Usage
```
  tableView.dequeue(TableViewCell.self, indexPath: indexPath)
```

## Extending Table View and Collection View
### Implementation
```
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
```

### Usage
```
class TableViewCell: UITableViewCell, NibLoadable, ReuseIdentifiable {}
class CollectionViewCell: UICollectionViewCell, NibLoadable, ReuseIdentifiable {}

//Register
tableView.register(TableViewCell.self)
collectionView.register(CollectionViewCell.self)

//Dequeue
let cvCell = tableView.dequeue(TableViewCell.self, indexPath: indexPath)
let tvCell = collectionView.dequeue(CollectionViewCell.self, indexPath: indexPath)
```
