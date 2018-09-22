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
	
	var news: News?
	
	override func viewDidLoad() {
        super.viewDidLoad()
    }

	func updateDetails(for news: News) {
		self.news = news
		
		numberOfViewsLabel.text = "Watched: \(news.header.numberOfViews ?? 0)"
		creationDateLabel.text = news.creationDate.description
		headerLabel.text = news.header.text.transformedByHtml
		contentLabel.text = news.content.transformedByHtml
	}
}
