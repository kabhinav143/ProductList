//  ProductDetailViewController.swift
//  AssignmentPowerPlay
//
//  Created by Abhinav Kumar on 24/09/25.

import UIKit

class ProductDetailViewController: UIViewController {

    @IBOutlet weak var productImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var ratingLabel: UILabel!
    @IBOutlet weak var specsLabel: UILabel!
    @IBOutlet weak var stock: UILabel!

    var product: Product?

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Details"
        setup()
    }

    private func setup() {
        guard let p = product else { return }

        // Basic info
        titleLabel.text = p.title
        priceLabel.text = String(format: "₹ %.2f", p.price)
        categoryLabel.text = p.category
        descriptionLabel.text = p.description
        stock.text = "\(p.stock ?? 0)"

        if let r = p.rating, let rate = r.rate, let cnt = r.count {
            ratingLabel.text = "⭐️ \(rate) (\(cnt))"
        } else {
            ratingLabel.text = "No rating"
        }


        productImageView.image = UIImage(systemName: "photo")
        ImageLoader.shared.loadImage(from: p.image) { [weak self] image in
            if let image = image {
                self?.productImageView.image = image
            }
        }

        setupSpecs(for: p.specs)
    }

    private func setupSpecs(for specs: Specs?) {
        guard let specs = specs else {
            specsLabel.text = "No specs available"
            return
        }

        var specsText = ""

        if let color = specs.color {
            specsText += "• Color: \(color)\n"
        }
        if let weight = specs.weight {
            specsText += "• Weight: \(weight)\n"
        }
        if let storage = specs.storage {
            specsText += "• Storage: \(storage)\n"
        }
        if let battery = specs.battery {
            specsText += "• Battery: \(battery)\n"
        }
        if let waterproof = specs.waterproof {
            specsText += "• Waterproof: \(waterproof ? "Yes" : "No")\n"
        }
        if let screen = specs.screen {
            specsText += "• Screen: \(screen)\n"
        }
        if let ram = specs.ram {
            specsText += "• RAM: \(ram)\n"
        }
        if let connection = specs.connection {
            specsText += "• Connection: \(connection)\n"
        }
        if let capacity = specs.capacity {
            specsText += "• Capacity: \(capacity)\n"
        }
        if let output = specs.output {
            specsText += "• Output: \(output)\n"
        }

        specsLabel.text = specsText.isEmpty ? "No specs available" : specsText
    }
}
