//
//  RealUIViewController.swift
//  MultiVideoStreaming
//
//  Created by Doug Hill on 10/18/18.
//  Copyright © 2018 doughill. All rights reserved.
//

import UIKit

class RealUIViewController: UIViewController {

    @IBOutlet var errorLabel: UILabel!
    @IBOutlet weak var infoLabel: UILabel!
    
    @IBOutlet var seekTimeSlider: UISlider!

    @IBOutlet var nextButton: UIButton!
    @IBOutlet var play: UIButton!

    @IBOutlet var chromecastButton: GCKUICastButton!

    @IBOutlet weak var avPlayerView: AVPlayerView!

    var userInitiatedSeekInProgress = false

    override func viewDidLoad()
    {
        super.viewDidLoad()

//        let customLabel = UILabel.init(frame: CGRect(x: 0, y: 0, width: self.view.bounds.width, height: 20))
//        customLabel.textColor = UIColor.white
//        customLabel.text = "Some very long text for the top to show the world and everyone else at that"
//        customLabel.textAlignment = .left
//        self.navigationItem.titleView = customLabel

//        self.parent?.navigationItem.rightBarButtonItems =
//            [
//                UIBarButtonItem.init(customView: GCKUICastButton.init())
//            ]
//        self.parent?.navigationItem.rightBarButtonItem = UIBarButtonItem.init(barButtonSystemItem: .organize, target: nil, action: nil)

//        backItem = UIBarButtonItem.init(barButtonSystemItem: .organize, target: nil, action: nil)
//        self.navigationItem.rightBarButtonItem = UIBarButtonItem.init(barButtonSystemItem: .edit, target: nil, action: nil)

        self.seekTimeSlider.setThumbImage(UIImage.init(named: "TimeSeekSliderThumb"), for: .normal)
        self.seekTimeSlider.setThumbImage(UIImage.init(named: "TimeSeekSliderThumb"), for: .highlighted)
    }

    @IBAction func playPauseButtonTapped(_ sender: Any)
    {

    }

    @IBAction func seekBackButtonTapped(_ sender: Any) {
    }

    @IBAction func nextButtonTapped(_ sender: Any) {
    }

    @IBAction func seekSliderValueChanged(_ sender: Any) {
        print("seekSliderValueChanged")
    }

    @IBAction func seekSliderTouchCancelled(_ sender: Any) {
        print("seekSliderTouchCancelled")
    }

    @IBAction func seekSliderDidEndOnExit(_ sender: Any) {
        print("seekSliderDidEndOnExit")
    }

    @IBAction func seekSliderEditingDidEnd(_ sender: Any) {
        print("seekSliderEditingDidEnd")
    }

    @IBAction func seekSliderTouchUpInside(_ sender: Any) {
        print("seekSliderTouchUpInside")
    }

    @IBAction func seekSliderTouchUpOutside(_ sender: Any) {
        print("seekSliderTouchUpOutside")
    }




}
