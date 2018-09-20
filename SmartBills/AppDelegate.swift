//
//  AppDelegate.swift
//  SmartBills
//
//  Created by Hunter Gregory on 9/19/18.
//  Copyright © 2018 Hunter Gregory. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        //change status bar color
        application.statusBarStyle = .lightContent
        return true
    }
}

