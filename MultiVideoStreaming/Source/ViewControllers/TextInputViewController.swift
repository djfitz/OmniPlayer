//
//  TextInputViewController.swift
//  MultiVideoStreaming
//
//  Created by Doug Hill on 7/27/19.
//  Copyright © 2019 doughill. All rights reserved.
//

import UIKit

class TextInputViewController: UIViewController, UITextFieldDelegate
{
    @IBOutlet weak var urlTextInput: UITextField!

    override func viewDidLoad()
    {
        super.viewDidLoad()

        MediaPlayerManager.mgr.avFoundationPlayer.beginSearchForRemoteDevices()
        MediaPlayerManager.mgr.chromecastPlayer.beginSearchForRemoteDevices()

        self.navigationController?.navigationBar.isTranslucent = true
        self.navigationController?.navigationBar.tintColor = .white
        self.navigationController?.navigationBar.barTintColor =  .clear
//        self.navigationController?.navigationBar.setBackgroundImage(#imageLiteral(resourceName: "bg"), for: .default)
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
