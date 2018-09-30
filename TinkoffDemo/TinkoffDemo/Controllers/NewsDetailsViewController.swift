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
	
	private lazy var dateFormatter: DateFormatter = {
		let formatter = DateFormatter()
		formatter.dateFormat = "MMM dd, yyyy"
		formatter.locale = Locale(identifier: "ru_RU")
		
		return formatter
	}()
	
	override func viewDidLoad() {
        super.viewDidLoad()
		
		updateSpinner()
		updateDetails()
    }

	func updateDetails() {
		headerLabel.text = news.header.text.transformedByHtml
		numberOfViewsLabel.text = "Просмотров: \(news.views)"
		creationDateLabel.text = "Создано: " + (formattedDate(from: news.details?.creationDate) ?? "")
		contentLabel.text = news.details?.content.transformedByHtml
	}
	
	func updateSpinner() {
		isSpinnerActive ? activityIndicator.startAnimating() : activityIndicator.stopAnimating()
	}
	
	private func formattedDate(from date: Date?) -> String? {
		guard let date = date else { return nil }

		return dateFormatter.string(from: date);
	}
}
