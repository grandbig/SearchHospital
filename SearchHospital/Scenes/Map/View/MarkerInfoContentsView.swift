//
//  MarkerInfoContentsView.swift
//  SearchHospital
//
//  Created by Takahiro Kato on 2018/05/06.
//  Copyright © 2018年 Takahiro Kato. All rights reserved.
//

import UIKit
import Cosmos

class MarkerInfoContentsView: UIView {

    // MARK: - IBOutlets
    @IBOutlet weak private var nameLabel: UILabel!
    @IBOutlet weak private var ratingLabel: UILabel!
    @IBOutlet weak private var placeImage: UIImageView!
    @IBOutlet weak private var ratingView: CosmosView!

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.xibViewSet()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        self.xibViewSet()
    }

    internal func xibViewSet() {
        if let view = Bundle.main.loadNibNamed("MarkerInfoContentsView", owner: self, options: nil)?.first as? UIView {
            view.frame = self.bounds
            self.addSubview(view)
        }
    }

    func setup(name: String, rating: Double) {
        nameLabel.text = name
        ratingLabel.text = String(rating)
        ratingView.rating = rating
        placeImage.image = R.image.noImageIcon()
    }

    func configure(image: UIImage?) {
        placeImage.image = image
    }
}
