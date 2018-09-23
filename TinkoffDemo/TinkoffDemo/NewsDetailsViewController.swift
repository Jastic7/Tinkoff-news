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
	
	var news: News!
	
	override func viewDidLoad() {
        super.viewDidLoad()
		
		updateDetails(for: news)
		activityIndicator.startAnimating()
    }

	func updateDetails(for news: News) {
		self.news = news
		activityIndicator.stopAnimating()
		
		headerLabel.text = news.header.text.transformedByHtml
		numberOfViewsLabel.text = "Просмотров: \(news.header.numberOfViews)"
		creationDateLabel.text = news.creationDate?.description
		contentLabel.text = news.content?.transformedByHtml
	}
}
