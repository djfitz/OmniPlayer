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
        self.mediaControlsView.toggleFullscreenButton?.setTitle("⇲", for: .normal)

        self.parent?.view.sizeThatFits(CGSize.zero)
        self.parent?.view.setNeedsLayout()

        UIView.animate(withDuration: 0.2, animations:
        {
            self.navigationController?.navigationBar.alpha = 0
        },
        completion:
        { (completed) in
            self.navigationController?.navigationBar.isHidden = true
        })

        MediaPlayerManager.mgr.uiUpdatesController?.showControls()
    }

    func exitFullscreen()
    {
        self.mediaControlsView.toggleFullscreenButton?.setTitle("⇱", for: .normal)

        Timer.scheduledTimer(withTimeInterval: 0.1, repeats: false)
        { (timer) in
            self.navigationController?.navigationBar.isHidden = false

            self.parent?.view.sizeThatFits(CGSize.zero)
            self.parent?.view.setNeedsLayout()

            UIView.animate(withDuration: 0.2, animations:
            {
                self.navigationController?.navigationBar.alpha = 1
            })
        }
    }
}
