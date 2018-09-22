//
//  NewsFeedViewController.swift
//  TinkoffDemo
//
//  Created by Andrey Morozov on 21.09.2018.
//  Copyright © 2018 Jastic7. All rights reserved.
//

import UIKit

class NewsFeedViewController: UIViewController {

	@IBOutlet weak var newsTableView: UITableView!
	
	var newsHeaders = [NewsHeader]()
	var transportLayer: TrasnportLayer!
	var newsService: NewsServiceInput!
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		newsTableView.register(UINib(nibName: "NewsTableViewCell", bundle: nil), forCellReuseIdentifier: "NewsCellIdentifier")
		newsTableView.dataSource = self
		newsTableView.delegate = self
		
		let baseURL = "https://api.tinkoff.ru/v"
		transportLayer = TrasnportLayer(baseUrl: baseURL)
		newsService = NewsService(transportLayer: transportLayer)
		newsService.output = self
		newsService.obtainNewsHeaders(from: 0, count: 20)
	}
}

extension NewsFeedViewController: UITableViewDataSource {
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return newsHeaders.count
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "NewsCellIdentifier", for: indexPath) as! NewsTableViewCell
		
		let header = newsHeaders[indexPath.row]
		cell.headerLabel.text = header.text
		cell.countLabel.text = "Count: \(header.numberOfViews ?? 0)"
		
		return cell
	}
}

extension NewsFeedViewController: UITableViewDelegate {
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		performSegue(withIdentifier: "detailNewsSegue", sender: nil)
		let selectedHeader = newsHeaders[indexPath.row]
		newsService.obtainNews(for: selectedHeader)
	}
}

extension NewsFeedViewController: NewsServiceOutput {
	func newsService(_ service: NewsServiceInput, didLoad news: News) {
		guard let detailsController = self.navigationController?.visibleViewController as? NewsDetailsViewController else {
			return
		}
		detailsController.updateDetails(for: news)
	}
	
	func newsService(_ service: NewsServiceInput, didLoad newsHeaders: [NewsHeader]) {
		self.newsHeaders = newsHeaders
		newsTableView.reloadData()
	}
}
