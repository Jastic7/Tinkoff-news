//
//  AppDelegate.swift
//  TinkoffDemo
//
//  Created by Andrey Morozov on 21.09.2018.
//  Copyright © 2018 Jastic7. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

	var window: UIWindow?
	private var persistanceController: PersistanceController!


	func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
		persistanceController = PersistanceController(modelName: "TinkoffDemo")
		
		guard let navigationController = window?.rootViewController as? UINavigationController,
			let newsFeedController = navigationController.viewControllers.first as? NewsFeedViewController else {
			fatalError("There is no NewsFeedVC")
		}
		
		let assembly = NewsAssembly()
		assembly.construct(newsFeedController, with: persistanceController)
		
		return true
	}

	func applicationWillResignActive(_ application: UIApplication) {
	}

	func applicationDidEnterBackground(_ application: UIApplication) {
		persistanceController.save()
	}

	func applicationWillEnterForeground(_ application: UIApplication) {
	}

	func applicationDidBecomeActive(_ application: UIApplication) {
	}

	func applicationWillTerminate(_ application: UIApplication) {
		persistanceController.save()
	}
}

