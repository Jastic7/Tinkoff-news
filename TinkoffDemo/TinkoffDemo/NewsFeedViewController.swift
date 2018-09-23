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
	var newsList = [News]()
	var transportLayer: TrasnportLayer!
	var newsService: NewsServiceInput!
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		newsTableView.register(UINib(nibName: "LoadingTableViewCell", bundle: nil), forCellReuseIdentifier: "LoadingCellIdentifier")
		newsTableView.register(UINib(nibName: "NewsTableViewCell", bundle: nil), forCellReuseIdentifier: "NewsCellIdentifier")
		newsTableView.dataSource = self
		newsTableView.delegate = self
		
		let baseURL = "https://api.tinkoff.ru/v"
		transportLayer = TrasnportLayer(baseUrl: baseURL)
		newsService = NewsService(transportLayer: transportLayer)
		newsService.output = self
		newsService.obtainNewsHeaders(from: 0, count: 20)
	}
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		guard let identifier = segue.identifier, identifier == "detailNewsSegue" else { return }
		guard let detailsViewController = segue.destination as? NewsDetailsViewController,
			let selectedNews = sender as? News else { return }
		
		detailsViewController.news = selectedNews
	}
	
	private func isLoadingCell(at indexPath: IndexPath) -> Bool {
//		return indexPath.row == newsHeaders.count
		return indexPath.row == newsList.count
	}
}

extension NewsFeedViewController: UITableViewDataSource {
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//		return newsHeaders.count + 1
		return newsList.count + 1
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		if isLoadingCell(at: indexPath) {
			return tableView.dequeueReusableCell(withIdentifier: "LoadingCellIdentifier", for: indexPath) as! LoadingTableViewCell
		}
		
		let cell = tableView.dequeueReusableCell(withIdentifier: "NewsCellIdentifier", for: indexPath) as! NewsTableViewCell
		
//		let header = newsHeaders[indexPath.row]
//		cell.headerLabel.text = header.text.transformedByHtml
//		let numberOfViews = "Просмотров: \(header.numberOfViews)"
//		cell.countLabel.text = numberOfViews
		let header = newsList[indexPath.row].header
		cell.headerLabel.text = header.text.transformedByHtml
		let numberOfViews = "Просмотров: \(header.numberOfViews)"
		cell.countLabel.text = numberOfViews
		
		return cell
	}
}

extension NewsFeedViewController: UITableViewDelegate {
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//		newsHeaders[indexPath.row].increaseCounter()
		newsList[indexPath.row].header.increaseCounter()
//		let selectedHeader = newsHeaders[indexPath.row]
		let selectedNews = newsList[indexPath.row]
		
		newsTableView.reloadRows(at: [indexPath], with: .fade)
//		performSegue(withIdentifier: "detailNewsSegue", sender: selectedHeader)
		performSegue(withIdentifier: "detailNewsSegue", sender: selectedNews)

		newsService.obtainNews(for: selectedNews.header)
	}
	
	func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
		guard isLoadingCell(at: indexPath) else { return }
		let last = UInt(newsList.count)
//		let last = UInt(newsHeaders.count)
		newsService.obtainNewsHeaders(from: last, count: 20)
	}
}

extension NewsFeedViewController: NewsServiceOutput {
	func newsService(_ service: NewsServiceInput, didLoad news: News) {
		guard let detailsController = self.navigationController?.visibleViewController as? NewsDetailsViewController else {
			return
		}
		
		let index = newsList.firstIndex(of: news)
		let oldNews = newsList[index!]
		var updatedNews = news
		updatedNews.header.numberOfViews = oldNews.header.numberOfViews
		newsList[index!] = updatedNews
	
		detailsController.updateDetails(for: updatedNews)
	}
	
	func newsService(_ service: NewsServiceInput, didLoad newsHeaders: [NewsHeader]) {
		let downloadedNewsList = newsHeaders.map {
			return News(header: $0, content: nil, creationDate: nil, lastModificationDate: nil)
		}
		newsList.append(contentsOf: downloadedNewsList)
//		self.newsHeaders.append(contentsOf: newsHeaders)
		newsTableView.reloadData()
	}
}
