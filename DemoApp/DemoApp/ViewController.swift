//
//  ViewController.swift
//  DemoApp
//
//  Created by Doug Hill on 8/15/19.
//  Copyright © 2019 Doug Hill. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad()
    {
        super.viewDidLoad()

        let bndle = Bundle.init(identifier: "com.doughill.MultiVideoPlayer")
        let storyboard = UIStoryboard(name: "MediaControls", bundle: bndle)

        let controller = storyboard.instantiateViewController(withIdentifier: "ViewControllerNameHere")
        self.present(controller, animated: true, completion: nil)

        print("\(self.view.subviews)")
    }


}

