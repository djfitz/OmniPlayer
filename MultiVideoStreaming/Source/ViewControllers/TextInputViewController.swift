//
//  TextInputViewController.swift
//  MultiVideoStreaming
//
//  Created by Doug Hill on 7/27/19.
//  Copyright © 2019 doughill. All rights reserved.
//

import UIKit

// ** Sample movie streams
// let url = URL.init(string: "http://breaqz.com/movies/Lego911gt3.mov")!
// let url = URL.init(string: "http://10.0.0.245:8080/camera/livestream.m3u8")!
// let url = URL.init(string: "http://devimages.apple.com/iphone/samples/bipbop/gear1/prog_index.m3u8")!
// let url = URL.init(string: "https://bitdash-a.akamaihd.net/content/sintel/hls/playlist.m3u8")!
// let url = URL.init(string: "https://bitdash-a.akamaihd.net/content/MI201109210084_1/m3u8s/f08e80da-bf1d-4e3d-8899-f0f6155f6efa.m3u8")!

// ** Sample live streams
// let url = URL.init(string: "http://csm-e.cds1.yospace.com/csm/live/74246610.m3u8")!

class TextInputViewController: UIViewController, UITextFieldDelegate
{
    @IBOutlet weak var urlTextInput: UITextField!

    override func viewDidLoad()
    {
        super.viewDidLoad()

        MediaPlayerManager.mgr.avFoundationPlayer.beginSearchForRemoteDevices()
        MediaPlayerManager.mgr.chromecastPlayer.beginSearchForRemoteDevices()

//        self.navigationController?.navigationBar.isTranslucent = true
//        self.navigationController?.navigationBar.tintColor = .white
//        self.navigationController?.navigationBar.setBackgroundImage(#imageLiteral(resourceName: "bg"), for: .default)
//        self.navigationController?.navigationBar.backgroundColor = .black
//        self.navigationController?.navigationBar.barTintColor =  .white

        self.title = "Media Home"

        self.navigationController?.edgesForExtendedLayout = [.top,.bottom,.left,.right]

        self.urlTextInput.delegate = self

        self.urlTextInput.becomeFirstResponder()
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool
    {
        print("\(textField.text!)")

        if let mvVC = self.storyboard?.instantiateViewController(withIdentifier: "MediaPlayerVCID") as? ViewController
        {
            if let mediaURLText = self.urlTextInput.text
            {
                mvVC.mediaURL = URL.init(string: mediaURLText)
                self.navigationController?.pushViewController(mvVC, animated: true)
            }
        }

        return true
    }
}
