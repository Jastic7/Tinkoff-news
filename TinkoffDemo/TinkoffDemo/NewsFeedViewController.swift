//
//  NewsFeedViewController.swift
//  TinkoffDemo
//
//  Created by Andrey Morozov on 21.09.2018.
//  Copyright © 2018 Jastic7. All rights reserved.
//

import UIKit
import CoreData

class NewsFeedViewController: UIViewController {

	@IBOutlet weak var newsTableView: UITableView!
	
	var transportLayer: TrasnportLayer!
	var newsService: NewsServiceInput!
	var dataSource: NewsCoreDataDataSource!
	var persistanceController: PersistanceController!
	
	lazy var fetchedResultController: NSFetchedResultsController<MONews> = {
		let pulicationDateSort = NSSortDescriptor(key: "header.publicationDate", ascending: false)
		
		let fetchRequest: NSFetchRequest = MONews.fetchRequest()
		fetchRequest.sortDescriptors = [pulicationDateSort]
		fetchRequest.fetchBatchSize = 20
		
		let context = persistanceController.readContext
		
		return NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
	}()
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		fetchedResultController.delegate = self
		
		do {
			try fetchedResultController.performFetch()
		} catch {
			fatalError("Cannot use FRC: \(error)")
		}
		
		newsTableView.register(UINib(nibName: "LoadingTableViewCell", bundle: nil), forCellReuseIdentifier: "LoadingCellIdentifier")
		newsTableView.register(UINib(nibName: "NewsTableViewCell", bundle: nil), forCellReuseIdentifier: "NewsCellIdentifier")
		newsTableView.dataSource = self
		newsTableView.delegate = self
		
		let baseURL = "https://api.tinkoff.ru/v"
		transportLayer = TrasnportLayer(baseUrl: baseURL)
		newsService = NewsService(transportLayer: transportLayer)
		newsService.output = self
		
		dataSource = NewsCoreDataDataSource(persistanceController: persistanceController)
	}
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		guard let identifier = segue.identifier, identifier == "detailNewsSegue" else { return }
		guard let detailsViewController = segue.destination as? NewsDetailsViewController,
			let selectedNews = sender as? MONews else { return }
		
		detailsViewController.news = selectedNews
	}
	
	private func isLoadingCell(at indexPath: IndexPath) -> Bool {
		guard let sections = fetchedResultController.sections else { return false }
		
		return indexPath.row == sections[indexPath.section].numberOfObjects
	}
}

extension NewsFeedViewController: UITableViewDataSource {
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		guard let sections = fetchedResultController.sections else { return 0 }
		
		return sections[section].numberOfObjects
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		if isLoadingCell(at: indexPath) {
			return tableView.dequeueReusableCell(withIdentifier: "LoadingCellIdentifier", for: indexPath) as! LoadingTableViewCell
		}
		
		let cell = tableView.dequeueReusableCell(withIdentifier: "NewsCellIdentifier", for: indexPath) as! NewsTableViewCell
		let news = fetchedResultController.object(at: indexPath)
		configure(cell: cell, with: news)
		
		return cell
	}
	
	func configure(cell: NewsTableViewCell, with news: MONews) {
		cell.headerLabel.text = news.header?.text.transformedByHtml
		cell.countLabel.text = "Просмотров: \(news.views)"
	}
}

extension NewsFeedViewController: UITableViewDelegate {
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		let selectedNews = fetchedResultController.object(at: indexPath)
		let context = persistanceController.readContext
		context.perform {
			selectedNews.views = selectedNews.views + 1
		}
		
		newsService.obtainDetails(for: selectedNews.header!.id)
		
		performSegue(withIdentifier: "detailNewsSegue", sender: selectedNews)
	}
}

extension NewsFeedViewController: NewsServiceOutput {
	
	func newsService(_ service: NewsServiceInput, didLoad details: NewsDetails, for newsId: String) {
		let context = persistanceController.writeContext
		context.perform {
			let predicate = NSPredicate(format: "header.id == %@", newsId)
			guard let moNews = self.persistanceController.find(by: MONews.fetchRequest(), with: predicate).first else {
				return
			}
			
			let moDetails = MONewsDetails(context: context)
			moDetails.content = details.content
			moDetails.creationDate = details.creationDate as NSDate
			moDetails.lastModificationDate = details.lastModificationDate as NSDate
			moNews.details = moDetails
			
			guard let detailsController = self.navigationController?.visibleViewController as? NewsDetailsViewController,
				detailsController.news.header?.id == moNews.header?.id else {
					return
			}
			
			DispatchQueue.main.async {
				detailsController.updateDetails(for: moNews)
			}
			self.persistanceController.save()
		}
	}
	
	func newsService(_ service: NewsServiceInput, didLoad newsHeaders: [NewsHeader]) {

	}
}

extension NewsFeedViewController: NSFetchedResultsControllerDelegate {
	
	func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
		newsTableView.beginUpdates()
	}
	
	func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
		
		switch type {
		case .insert:
			newsTableView.insertRows(at: [newIndexPath!], with: .fade)
		case .update:
			newsTableView.reloadRows(at: [newIndexPath!], with: .fade)
		default:
			break
		}
	}
	
	func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
		newsTableView.endUpdates()
	}
}
