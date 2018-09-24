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
	
	var newsList = [News]()
	var transportLayer: TrasnportLayer!
	var newsService: NewsServiceInput!
	let dataSource = NewsCoreDataDataSource()
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		newsList = dataSource.obtainAllEntities()
		
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
		return indexPath.row == newsList.count
	}
}

extension NewsFeedViewController: UITableViewDataSource {
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return newsList.count + 1
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		if isLoadingCell(at: indexPath) {
			return tableView.dequeueReusableCell(withIdentifier: "LoadingCellIdentifier", for: indexPath) as! LoadingTableViewCell
		}
		
		let cell = tableView.dequeueReusableCell(withIdentifier: "NewsCellIdentifier", for: indexPath) as! NewsTableViewCell
		
		let news = newsList[indexPath.row]
		cell.headerLabel.text = news.header.text.transformedByHtml
		cell.countLabel.text = "Просмотров: \(news.views)"
		
		return cell
	}
}

extension NewsFeedViewController: UITableViewDelegate {
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		newsList[indexPath.row].addView()
		let selectedNews = newsList[indexPath.row]
		
		newsTableView.reloadRows(at: [indexPath], with: .fade)
		performSegue(withIdentifier: "detailNewsSegue", sender: selectedNews)

		newsService.obtainDetails(for: selectedNews)
	}
	
	func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
		guard isLoadingCell(at: indexPath) else { return }
		let last = UInt(newsList.count)
		newsService.obtainNewsHeaders(from: last, count: 20)
	}
}

extension NewsFeedViewController: NewsServiceOutput {
	
	func newsService(_ service: NewsServiceInput, didLoad details: NewsDetails, for news: News) {
		guard let indexOfNews = newsList.firstIndex(of: news) else { return }
		newsList[indexOfNews].details = details
		
		guard let detailsController = self.navigationController?.visibleViewController as? NewsDetailsViewController,
			detailsController.news == news else {
			return
		}
		
		detailsController.updateDetails(for: newsList[indexOfNews])
	}
	
	func newsService(_ service: NewsServiceInput, didLoad newsHeaders: [NewsHeader]) {
		let downloadedNewsList = newsHeaders.map { return News(header: $0) }
		newsList.append(contentsOf: downloadedNewsList)
		dataSource.save(entities: downloadedNewsList)
		newsTableView.reloadData()
	}
}
