import UIKit

final class ProductsListViewController: UITableViewController, StoryboardInstantiable {
    var viewModel: ProductsListViewModel!
    var didCellForRow: ((UITableView, Product) -> UITableViewCell?)?

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        bind(to: viewModel)
        viewModel.viewDidLoad()
    }

    private func bind(to viewModel: ProductsListViewModel) {
        viewModel.products.observe(on: self) { [weak self] _ in self?.tableView.reloadData() }
        viewModel.error.observe(on: self) { [weak self] in self?.showError($0) }
    }

    private func showError(_ error: String) {
        guard !error.isEmpty else { return }

        let alert = UIAlertController(title: "Error", message: error, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }

    static func create(with viewModel: ProductsListViewModel) -> ProductsListViewController {
        let view = ProductsListViewController.instantiateViewController()
        view.viewModel = viewModel
        return view
    }
}

// MARK: - UITableViewDataSource, UITableViewDelegate

extension ProductsListViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.products.value.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let product = viewModel.products.value[indexPath.row]
        guard let cell = didCellForRow?(tableView, product) else {
            assertionFailure("Cannot dequeue reusable cell \(ProductListItemCell.self) with reuseIdentifier: \(ProductListItemCell.reuseIdentifier)")
            return UITableViewCell()
        }

        return cell
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return ProductListItemCell.height
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        viewModel.didSelectItem(at: indexPath.row)
    }
}
