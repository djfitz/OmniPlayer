//
//  MediaControlsViewController.swift
//  MultiVideoStreaming
//
//  Created by Doug Hill on 10/16/18.
//  Copyright © 2018 doughill. All rights reserved.
//

import UIKit

public class MediaControlsViewController: UIViewController
{
    @IBOutlet var mediaControlsView: MediaPlayerControlsView!

    public var isFullscreen = false
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

    override public func viewDidLoad()
    {
        super.viewDidLoad()

        MediaPlayerManager.mgr.registerPlayerUICollection(uiCollection: self.mediaControlsView)
    }

    override public func viewDidAppear(_ animated: Bool)
    {
        super.viewDidAppear(animated)

        if !self.isFullscreen
        {
            let nsecs = DispatchTime.now().uptimeNanoseconds + UInt64( Double( NSEC_PER_SEC) * 0.9 )
            let fireTime = DispatchTime(uptimeNanoseconds: nsecs
            )
            DispatchQueue
                .main
                .asyncAfter( deadline: fireTime )
            {
                self.isFullscreen = true
            }
        }
    }

    @IBAction public func toggleFullscreen(_ sender: Any)
    {
        self.isFullscreen = !self.isFullscreen
    }

    public func enterFullscreen()
    {
        self.mediaControlsView.toggleFullscreenButton?.setTitle("⇲", for: .normal)

        if let navBar = self.navigationController?.navigationBar
        {
            UIView.animate(withDuration: 0.2, animations:
            {
                navBar.center = CGPoint(x:navBar.center.x, y:(navBar.center.y - 20))
            },
            completion:
            { (completed) in
                navBar.isHidden = true
                navBar.center = CGPoint(x:navBar.center.x, y:(navBar.center.y + 20))

                self.parent?.view.setNeedsLayout()
            })
        }

        MediaPlayerManager.mgr.uiUpdatesController?.showControls()
    }

    public func exitFullscreen()
    {
        self.mediaControlsView.toggleFullscreenButton?.setTitle("⇱", for: .normal)

        Timer.scheduledTimer(withTimeInterval: 0.1, repeats: false)
        { (timer) in
            self.navigationController?.navigationBar.isHidden = false

            self.parent?.view.setNeedsLayout()

            UIView.animate(withDuration: 0.2, animations:
            {
                self.navigationController?.navigationBar.alpha = 1
            })
        }
    }
}
