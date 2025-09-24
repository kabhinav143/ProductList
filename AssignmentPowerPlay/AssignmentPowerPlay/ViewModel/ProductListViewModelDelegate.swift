//
//  ProductListViewModelDelegate.swift
//  AssignmentPowerPlay
//
//  Created by Abhinav Kumar on 24/09/25.
//

import Foundation
import UIKit

protocol ProductListViewModelDelegate: AnyObject {
    func didStartLoading()
    func didFinishLoading()
    func didLoadNewProducts(newIndexPaths: [IndexPath]?)
    func didFailWithError(_ error: Error)
    func showNoDataView()
    func didSelectProduct(_ product: Product)
}

final class ProductListViewModel {
    weak var delegate: ProductListViewModelDelegate?

    private(set) var products: [Product] = []
    private var isFetching = false
    private var currentPage = 0
    private var limit = 3
    private var hasMore = true

    func refresh() {
      
        products.removeAll()
        currentPage = 0
        hasMore = true
        fetchNextPage()
    }

    func fetchNextPage() {
        guard !isFetching, hasMore else { return }
        isFetching = true
        delegate?.didStartLoading()

        APIService.shared.fetchProducts(page: currentPage, limit: limit) { [weak self] result in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.isFetching = false
                self.delegate?.didFinishLoading()

                switch result {
                case .success(let resp):
                    if resp.data.isEmpty && self.products.isEmpty {
                        self.delegate?.showNoDataView()
                    } else {
                        let start = self.products.count
                        self.products.append(contentsOf: resp.data)
                        let end = self.products.count - 1
                        var indexPaths: [IndexPath] = []
                        if start <= end {
                            for i in start...end {
                                indexPaths.append(IndexPath(row: i, section: 0))
                            }
                        }
                        self.delegate?.didLoadNewProducts(newIndexPaths: indexPaths)
                    }
                    if let next = resp.nextPage {
                        self.currentPage = next
                        self.hasMore = true
                    } else if let p = resp.pagination, let page = p.page, let limit = p.limit, let total = p.total {
                        if (page * limit) < total {
                            self.currentPage = page + 1
                            self.hasMore = true
                        } else {
                            self.hasMore = false
                        }
                    } else {
                        self.hasMore = false
                    }

                case .failure(let error):
                    self.delegate?.didFailWithError(error)
                }
            }
        }
    }

    func product(at index: Int) -> Product? {
        guard index >= 0, index < products.count else { return nil }
        return products[index]
    }

    func selectProduct(at index: Int) {
        guard let p = product(at: index) else { return }
        delegate?.didSelectProduct(p)
    }
}
