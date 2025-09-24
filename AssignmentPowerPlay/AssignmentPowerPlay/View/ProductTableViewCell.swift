//
//  ProductTableViewCell.swift
//  AssignmentPowerPlay
//
//  Created by Abhinav Kumar on 24/09/25.
//


import UIKit

class ProductTableViewCell: UITableViewCell {
    @IBOutlet weak var productImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        productImageView.contentMode = .scaleAspectFill
        productImageView.clipsToBounds = true
    }

    func configure(with product: Product) {
        titleLabel.text = product.title
        descriptionLabel.text = product.description
        categoryLabel.text = product.category
        priceLabel.text = String(format: "₹ %.2f", product.price) // change currency if needed

        // Placeholder first
        productImageView.image = UIImage(systemName: "photo")

        // Lazy load image
        ImageLoader.shared.loadImage(from: product.image) { [weak self] image in
            // simple check: set image if available
            if let image = image {
                self?.productImageView.image = image
            } else {
                self?.productImageView.image = UIImage(systemName: "photo")
            }
        }
    }
}
