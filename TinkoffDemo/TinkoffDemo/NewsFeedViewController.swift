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
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		for i in 0...10 {
			let header = "News header #\(i)"
			let numberOfViews: UInt = 0
			let publicationDate = 1513684913000
			let id = "\(i)"
			let newsHeader = NewsHeader.init(id: id, text: header, publicationDate: publicationDate, numberOfViews: numberOfViews)
			newsHeaders.append(newsHeader)
		}
		
		newsTableView.register(UINib(nibName: "NewsTableViewCell", bundle: nil), forCellReuseIdentifier: "NewsCellIdentifier")
		newsTableView.dataSource = self
		newsTableView.delegate = self
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
		cell.countLabel.text = "Count: \(header.numberOfViews)"
		
		return cell
	}
}

extension NewsFeedViewController: UITableViewDelegate {
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		performSegue(withIdentifier: "detailNewsSegue", sender: nil)
	}
}
