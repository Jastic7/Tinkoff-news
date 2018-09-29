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
	
	var newsService: NewsServiceInput!
	var dataSource: NewsCoreDataDataSource<NewsFeedViewController>!
	
	private let newsCellIdentifier = "NewsCellIdentifier"
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		newsTableView.register(UINib(nibName: NewsTableViewCell.nibName, bundle: nil), forCellReuseIdentifier: "LoadingCellIdentifier")
		newsTableView.register(UINib(nibName: NewsTableViewCell.nibName, bundle: nil), forCellReuseIdentifier: newsCellIdentifier)
		newsTableView.dataSource = self
		newsTableView.delegate = self
		newsTableView.estimatedRowHeight = 80

//		newsService.obtainNewsHeaders(from: 0, count: 20)
	}
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		guard let identifier = segue.identifier, identifier == "detailNewsSegue" else { return }
		guard let detailsViewController = segue.destination as? NewsDetailsViewController,
			let selectedNews = sender as? News else { return }
		
		detailsViewController.news = selectedNews
		detailsViewController.isSpinnerActive = true
	}
	
	private func isLoadingCell(at indexPath: IndexPath) -> Bool {
		return indexPath.row == dataSource.numberOfEntities(in: indexPath.section)
	}
}

extension NewsFeedViewController: UITableViewDataSource {
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return dataSource.numberOfEntities(in: section) + 1
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		if isLoadingCell(at: indexPath) {
			return tableView.dequeueReusableCell(withIdentifier: "LoadingCellIdentifier", for: indexPath) as! LoadingTableViewCell
		}
		
		let cell = tableView.dequeueReusableCell(withIdentifier: newsCellIdentifier, for: indexPath) as! NewsTableViewCell
		let news = dataSource.entity(at: indexPath)
		configure(cell: cell, with: news)
		
		return cell
	}
	
	func configure(cell: NewsTableViewCell, with news: News) {
		cell.headerLabel.text = news.header.text.transformedByHtml
		cell.countLabel.text = "Просмотров: \(news.views)"
	}
}

extension NewsFeedViewController: UITableViewDelegate {
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		var selectedNews = dataSource.entity(at: indexPath)
		selectedNews.addView()
		dataSource.save(entities: [selectedNews])
		
		newsService.obtainDetails(for: selectedNews)
		
		performSegue(withIdentifier: "detailNewsSegue", sender: selectedNews)
	}
	
	func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
		guard isLoadingCell(at: indexPath) else {
			return
		}
		
		let last = UInt(dataSource.numberOfEntities(in: indexPath.section))
		newsService.obtainNewsHeaders(from: last, count: 20)
	}
}

extension NewsFeedViewController: NewsServiceOutput {
	
	func newsService(_ service: NewsServiceInput, didLoad details: NewsDetails, for news: News) {
		var updatedNews = news
		updatedNews.details = details
		
		dataSource.save(entities: [updatedNews]) {
			guard let detailsController = self.navigationController?.visibleViewController as? NewsDetailsViewController,
				detailsController.news == updatedNews else {
					return
			}

			DispatchQueue.main.async {
				detailsController.news = updatedNews
				detailsController.isSpinnerActive = false
				detailsController.updateDetails()
				detailsController.updateSpinner()
			}
		}
	}
	
	func newsService(_ service: NewsServiceInput, didLoad newsHeaders: [NewsHeader]) {
		let downloadedNews = newsHeaders.map { News(header: $0) }
		dataSource.save(entities: downloadedNews)
	}
}

extension NewsFeedViewController: DataSourceOutput {
	
	func dataSourceWillChangeEntities() {
		newsTableView.beginUpdates()
	}
	
	func dataSource(didChange entity: News, with type: DataSourceChangeType) {
		switch type {
		case .insert(let insertPath):
			newsTableView.insertRows(at: [insertPath], with: .fade)
		case .update(at: let updatePath):
			newsTableView.reloadRows(at: [updatePath], with: .fade)
		default:
			break
		}
	}
	
	func dataSourceDidChangeEntities() {
		newsTableView.endUpdates()
	}
}
