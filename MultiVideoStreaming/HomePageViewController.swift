//
//  HomePageViewController.swift
//  MultiVideoStreaming
//
//  Created by Doug Hill on 10/18/18.
//  Copyright © 2018 doughill. All rights reserved.
//

import UIKit

class HomePageViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        let customLabel = UILabel.init(frame: CGRect(x: 0, y: 0, width: self.view.bounds.width, height: 20))
        customLabel.textColor = UIColor.white
        customLabel.text = "Homer"
        customLabel.textAlignment = .center
        self.navigationItem.titleView = customLabel

        self.navigationController?.navigationBar.backgroundColor = UIColor.red
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
