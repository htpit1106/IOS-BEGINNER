import UIKit


class ReminderListViewController: UICollectionViewController {
//    static let instanse = ReminderListViewController()

    var dataSource: DataSource?


    override func viewDidLoad() {
        super.viewDidLoad()


        let listLayout = listLayout()
        collectionView.collectionViewLayout = listLayout

        let cellRegistration = UICollectionView.CellRegistration(handler: cellRegistrationHandler)

        
//
//        let cellRegistration = UICollectionView.CellRegistration {
//            (cell: UICollectionViewListCell, indexPath: IndexPath, itemIdentifier: String) in
//            let reminder = Reminder.sampleData[indexPath.item]
//            var contentConfiguration = cell.defaultContentConfiguration()
//            contentConfiguration.text = reminder.title
//            contentConfiguration.secondaryTextProperties.font = UIFont.preferredFont(
//                        forTextStyle: .caption1)
//            
//            cell.contentConfiguration = contentConfiguration
//        }


        dataSource = DataSource(collectionView: collectionView) {
            (collectionView: UICollectionView, indexPath: IndexPath, itemIdentifier: String) in
            return collectionView.dequeueConfiguredReusableCell(
                using: cellRegistration, for: indexPath, item: itemIdentifier)
        }


        var snapshot = Snapshot()
        snapshot.appendSections([0])
        snapshot.appendItems(Reminder.sampleData.map { $0.title })
        dataSource?.apply(snapshot)


        collectionView.dataSource = dataSource
    }


    private func listLayout() -> UICollectionViewCompositionalLayout {
        var listConfiguration = UICollectionLayoutListConfiguration(appearance: .grouped)
        listConfiguration.showsSeparators = false
        listConfiguration.backgroundColor = .clear
        return UICollectionViewCompositionalLayout.list(using: listConfiguration)
    }
}
