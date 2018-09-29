//
//  NewsDetailsViewController.swift
//  TinkoffDemo
//
//  Created by Andrey Morozov on 22.09.2018.
//  Copyright © 2018 Jastic7. All rights reserved.
//

import UIKit

class NewsDetailsViewController: UIViewController {

	@IBOutlet weak var numberOfViewsLabel: UILabel!
	@IBOutlet weak var creationDateLabel: UILabel!
	@IBOutlet weak var headerLabel: UILabel!
	@IBOutlet weak var contentLabel: UILabel!
	@IBOutlet weak var activityIndicator: UIActivityIndicatorView!
	
	var isSpinnerActive: Bool = false
	var news: News!
	
	override func viewDidLoad() {
        super.viewDidLoad()
		
		updateSpinner()
		updateDetails()
    }

	func updateDetails() {
		headerLabel.text = news.header.text.transformedByHtml
		numberOfViewsLabel.text = "Просмотров: \(news.views)"
		creationDateLabel.text = news.details?.creationDate.description
		contentLabel.text = news.details?.content.transformedByHtml
	}
	
	func updateSpinner() {
		isSpinnerActive ? activityIndicator.startAnimating() : activityIndicator.stopAnimating()
	}
}
