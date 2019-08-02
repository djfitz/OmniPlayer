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

    override func viewDidLoad()
    {
        super.viewDidLoad()

        MediaPlayerManager.mgr.registerPlayerUICollection(uiCollection: self.mediaControlsView)
    }
}
