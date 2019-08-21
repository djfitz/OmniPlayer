//
//  MediaControlsViewController.swift
//  MultiVideoStreaming
//
//  Created by Doug Hill on 10/16/18.
//  Copyright © 2018 doughill. All rights reserved.
//

import UIKit

class MediaControlsViewController: UIViewController {
    @IBOutlet var backButton: UIButton!
    @IBOutlet var playButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()

//        self.timeSeekSlider.setThumbImage(UIImage(named: "TimeSeekSliderThumb"), for: .normal)
//        self.timeSeekSlider.setThumbImage(UIImage(named: "TimeSeekSliderThumb"), for: .selected)
//        self.timeSeekSlider.setThumbImage(UIImage(named: "TimeSeekSliderThumb"), for: .highlighted)
    }

    @IBAction func backButtonTapped(_ sender: Any) {
        print("Back button tapped")
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
