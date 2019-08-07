//
//  MediaControlsViewController.swift
//  MultiVideoStreaming
//
//  Created by Doug Hill on 10/16/18.
//  Copyright © 2018 doughill. All rights reserved.
//

import UIKit

class MediaControlsViewController: UIViewController
{
    @IBOutlet var mediaControlsView: MediaPlayerControlsView!

    var isFullscreen = false
    {
        didSet
        {
            if self.isFullscreen
            {
                self.enterFullscreen()
            }
            else
            {
                self.exitFullscreen()
            }
        }
    }

    override func viewDidLoad()
    {
        super.viewDidLoad()

        MediaPlayerManager.mgr.registerPlayerUICollection(uiCollection: self.mediaControlsView)
    }

    @IBAction func toggleFullscreen(_ sender: Any)
    {
        self.isFullscreen = !self.isFullscreen
    }

    func enterFullscreen()
    {
        self.navigationController?.navigationBar.isHidden = true
    }

    func exitFullscreen()
    {
        self.navigationController?.navigationBar.isHidden = false
    }
}
