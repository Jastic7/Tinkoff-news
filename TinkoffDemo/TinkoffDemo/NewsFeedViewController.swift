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
	
	var news: [String]!
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		news = [String]()
		for i in 0...10 {
			news.append("News header #\(i)")
		}
		
		newsTableView.register(UINib(nibName: "NewsTableViewCell", bundle: nil), forCellReuseIdentifier: "NewsCellIdentifier")
		newsTableView.dataSource = self
		newsTableView.delegate = self
	}
	
}

extension NewsFeedViewController: UITableViewDataSource {
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return news.count
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "NewsCellIdentifier", for: indexPath) as! NewsTableViewCell
		
		cell.headerLabel.text = news[indexPath.row]
		cell.countLabel.text = "Count: 0"
		
		return cell
	}
}

extension NewsFeedViewController: UITableViewDelegate {
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		performSegue(withIdentifier: "detailNewsSegue", sender: nil)
	}
}
