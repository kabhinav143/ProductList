//
//  ProductListViewController.swift
//  AssignmentPowerPlay
//
//  Created by Abhinav Kumar on 24/09/25.
//


import UIKit

class ProductListViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!

    private let viewModel = ProductListViewModel()

    // center loader for initial load
    private let centerLoader = UIActivityIndicatorView(style: .large)
    // footer loader for pagination
    private let footerLoader = UIActivityIndicatorView(style: .medium)

    // simple no data / error views
    private var noDataLabel: UILabel = {
        let v = UILabel()
        v.text = "No products found"
        v.textAlignment = .center
        v.isHidden = true
        return v
    }()

    private var errorView: UIView = {
        let v = UIView()
        v.isHidden = true
        v.backgroundColor = .systemBackground
        return v
    }()
    private var retryButton: UIButton = {
        let b = UIButton(type: .system)
        b.setTitle("Retry", for: .normal)
        return b
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Products"

        tableView.dataSource = self
        tableView.delegate = self

        // register nib/class if needed. We used prototype cell in storyboard — no registration needed.
        viewModel.delegate = self

        setupUI()
        viewModel.fetchNextPage()
    }

    private func setupUI() {
        // center loader
        centerLoader.hidesWhenStopped = true
        centerLoader.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(centerLoader)
        NSLayoutConstraint.activate([
            centerLoader.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            centerLoader.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])

        // table footer loader
        footerLoader.hidesWhenStopped = true

        // noDataLabel
        noDataLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(noDataLabel)
        NSLayoutConstraint.activate([
            noDataLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            noDataLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            noDataLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            noDataLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])

        // errorView with retry
        errorView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(errorView)
        NSLayoutConstraint.activate([
            errorView.topAnchor.constraint(equalTo: view.topAnchor),
            errorView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            errorView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            errorView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
        let errorLabel = UILabel()
        errorLabel.text = "No internet connection"
        errorLabel.textAlignment = .center
        errorLabel.translatesAutoresizingMaskIntoConstraints = false
        errorView.addSubview(errorLabel)

        retryButton.translatesAutoresizingMaskIntoConstraints = false
        errorView.addSubview(retryButton)
        retryButton.addTarget(self, action: #selector(retryTapped), for: .touchUpInside)

        NSLayoutConstraint.activate([
            errorLabel.centerXAnchor.constraint(equalTo: errorView.centerXAnchor),
            errorLabel.centerYAnchor.constraint(equalTo: errorView.centerYAnchor, constant: -20),
            retryButton.topAnchor.constraint(equalTo: errorLabel.bottomAnchor, constant: 12),
            retryButton.centerXAnchor.constraint(equalTo: errorView.centerXAnchor)
        ])
    }

    @objc private func retryTapped() {
        errorView.isHidden = true
        noDataLabel.isHidden = true
        viewModel.refresh()
    }
}

// MARK: - TableView DataSource & Delegate
extension ProductListViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
         return viewModel.products.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ProductTableViewCell", for: indexPath) as? ProductTableViewCell else {
            return UITableViewCell()
        }

        let product = viewModel.products[indexPath.row]
        cell.configure(with: product)
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        viewModel.selectProduct(at: indexPath.row) // uses delegate to tell VC to navigate
    }

    // pagination trigger: when user scrolls near bottom
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        let frameHeight = scrollView.frame.size.height

        if offsetY > contentHeight - frameHeight - 100 { // 100pt before bottom
            viewModel.fetchNextPage()
        }
    }
}

// MARK: - ViewModel Delegate
extension ProductListViewController: ProductListViewModelDelegate {
    func didStartLoading() {
        // if no data yet -> center loader, otherwise show footer loader
        if viewModel.products.isEmpty {
            centerLoader.startAnimating()
            tableView.isHidden = true
            noDataLabel.isHidden = true
        } else {
            footerLoader.startAnimating()
            tableView.tableFooterView = footerLoader
        }
    }

    func didFinishLoading() {
        centerLoader.stopAnimating()
        footerLoader.stopAnimating()
        tableView.isHidden = false
        tableView.tableFooterView = nil
    }

    func didLoadNewProducts(newIndexPaths: [IndexPath]?) {
        noDataLabel.isHidden = true
        errorView.isHidden = true
        if let indexPaths = newIndexPaths, !indexPaths.isEmpty, viewModel.products.count > 0 {
            // insert new rows
            tableView.beginUpdates()
            tableView.insertRows(at: indexPaths, with: .automatic)
            tableView.endUpdates()
        } else {
            tableView.reloadData()
        }
    }

    func didFailWithError(_ error: Error) {
        // detect no internet
        let ns = error as NSError
        if ns.domain == NSURLErrorDomain && ns.code == NSURLErrorNotConnectedToInternet {
            // show error screen with retry
            errorView.isHidden = false
            tableView.isHidden = true
            centerLoader.stopAnimating()
        } else {
            // simple alert for other errors
            let alert = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
        }
    }

    func showNoDataView() {
        noDataLabel.isHidden = false
        tableView.isHidden = true
        centerLoader.stopAnimating()
    }

    func didSelectProduct(_ product: Product) {
        // navigate to detail
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let detail = storyboard.instantiateViewController(withIdentifier: "ProductDetailVC") as? ProductDetailViewController else { return }
        detail.product = product
        navigationController?.pushViewController(detail, animated: true)
    }
}
