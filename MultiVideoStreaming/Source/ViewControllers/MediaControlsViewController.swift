//
//  MediaControlsViewController.swift
//  MultiVideoStreaming
//
//  Created by Doug Hill on 10/16/18.
//  Copyright © 2018 doughill. All rights reserved.
//

import UIKit
import GoogleCast
import MediaPlayer

class MediaControlsViewController: UIViewController {
    @IBOutlet var backButton: UIButton!
    @IBOutlet var playButton: UIButton!
    @IBOutlet weak var playPauseButton: UIButton!
    @IBOutlet weak var seekTimeSlider: UISlider!

    var isSliderChanging = false

    @IBOutlet weak var activitySpinner: UIActivityIndicatorView!

    @IBOutlet weak var infoLabel: UILabel!
    @IBOutlet weak var errorLabel: UILabel!

    @IBOutlet weak var remoteButtonsContainerStack: UIStackView!
    @IBOutlet weak var chromecastButton: GCKUIMultistateButton!
    @IBOutlet weak var airplayButton: MPVolumeView!

    @IBOutlet weak var avPlayerView: AVPlayerView!
    
    deinit
    {
        AVFoundationMediaPlayerManager.mgr.removeObserver(self, forKeyPath: "status")
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.init("PlaybackTimeObserver"), object: nil)

        AVFoundationMediaPlayerManager.mgr.player.replaceCurrentItem(with: nil)
    }

    override func viewDidLoad()
    {
        super.viewDidLoad()

        self.avPlayerView.player = AVFoundationMediaPlayerManager.mgr.player

        AVFoundationMediaPlayerManager.mgr.addObserver(self, forKeyPath: "status", options: .new, context: nil)

        NotificationCenter.default.addObserver(self, selector: #selector(playbackTimeUpdated), name: NSNotification.Name.init("PlaybackTimeObserver"), object: nil)

        self.seekTimeSlider.setThumbImage(UIImage(named: "TimeSeekSliderThumb"), for: .normal)
        self.seekTimeSlider.setThumbImage(UIImage(named: "TimeSeekSliderThumb"), for: .selected)
        self.seekTimeSlider.setThumbImage(UIImage(named: "TimeSeekSliderThumb"), for: .highlighted)

        self.infoLabel.text = AVFoundationMediaPlayerManager.mgr.currentMediaItem?.title
        self.infoLabel.isHidden = false
        self.errorLabel.text = ""
    }

    @objc func playbackTimeUpdated( notif: Notification)
    {
//        print("\(notif)")

        if let currentCMTime:CMTime = notif.object as? CMTime
        {
            let currentTimeSeconds = currentCMTime.seconds
            let dur = AVFoundationMediaPlayerManager.mgr.playerItem?.duration
            if let duration = dur?.seconds
            {
                if duration > 0 && !self.isSliderChanging && !AVFoundationMediaPlayerManager.mgr.isSeeking
                {
                    let fracTimeElapsed = currentTimeSeconds / duration
                    self.seekTimeSlider.value = Float(fracTimeElapsed)
                }
            }
        }
    }

    @IBAction func backButtonTapped(_ sender: Any)
    {
        print("Back button tapped")

//        AVFoundationMediaPlayerManager.mgr.sk`
    }

    @IBAction func playPauseButtonTapped(_ sender: Any)
    {
        switch AVFoundationMediaPlayerManager.mgr.status
        {
            case .readyToPlay:
                AVFoundationMediaPlayerManager.mgr.play()

            case .paused:
                AVFoundationMediaPlayerManager.mgr.play()

            case .playing:
                AVFoundationMediaPlayerManager.mgr.pause()

            case .failed:
                AVFoundationMediaPlayerManager.mgr.play()

            case .loading:
                AVFoundationMediaPlayerManager.mgr.play()

            case .unknown:
                AVFoundationMediaPlayerManager.mgr.play()

            case .playedToEnd:
                self.seekTimeSlider.value = 0

                AVFoundationMediaPlayerManager.mgr.seek(to: CMTime.zero)
                { (cancelled) in
                    if !cancelled
                    {
                        AVFoundationMediaPlayerManager.mgr.play()
                        self.playPauseButton.setImage(#imageLiteral(resourceName: "Pause"), for: .normal)
                    }
                    else
                    {
                        self.playPauseButton.setImage(#imageLiteral(resourceName: "PlayButton"), for: .normal)
                    }
                }

            case .buffering:
                AVFoundationMediaPlayerManager.mgr.pause()
        }
    }
    
    @IBAction func forwardButtonTapped(_ sender: Any)
    {
    }
    
    //
    
    @IBAction func sliderValueChanged(_ sender: Any)
    {
        print("sliderValueChanged \(sender)")
        self.isSliderChanging = true
    }
    
    @IBAction func sliderEditingChanged(_ sender: Any)
    {
        print("sliderEditingChanged \(sender)")
        self.isSliderChanging = true
    }
    
    @IBAction func sliderTouchCancelled(_ sender: Any)
    {
        print("sliderTouchCancelled \(sender)")
        self.isSliderChanging = false
    }
    
    @IBAction func sliderEditingDidEnd(_ sender: Any)
    {
        print("sliderEditingDidEnd \(sender)")
        self.isSliderChanging = false
    }
    
    @IBAction func sliderDidEndOnExit(_ sender: Any)
    {
        print("sliderDidEndOnExit \(sender)")
        self.isSliderChanging = false
    }

    @IBAction func sliderTouchUpInside(_ sender: Any)
    {
        print("sliderTouchUpInside \(sender)")

        let currentSliderValue = Double(self.seekTimeSlider!.value)
        let dur = AVFoundationMediaPlayerManager.mgr.playerItem?.duration
        if let duration = dur?.seconds
        {
            var newSecondsElapsed = currentSliderValue * duration
            if duration - newSecondsElapsed < 0.12
            {
                newSecondsElapsed = duration
            }

            AVFoundationMediaPlayerManager.mgr.pause()

            AVFoundationMediaPlayerManager.mgr.seek(to: CMTime(seconds: newSecondsElapsed, preferredTimescale: CMTimeScale(1)))
            { (cancelled) in
                self.isSliderChanging = false
                AVFoundationMediaPlayerManager.mgr.play()
            }
        }
    }

    @IBAction func sliderTouchUpOutside(_ sender: Any)
    {
        print("sliderTouchUpOutside \(sender)")
        self.isSliderChanging = false
    }

    //
    
    
    // * observeValue(forKeyPath…)
    @objc override func observeValue(forKeyPath keyPath: String?,
                                     of object: Any?,
                                     change: [NSKeyValueChangeKey : Any]?,
                                     context: UnsafeMutableRawPointer?)
    {
        print("Observed Value change:\n\(String.init(describing: keyPath))\n")
        print("Object:\n\(String(describing: object))\n")
        print("Change:\n\(String(describing: change))\n")

        if keyPath == "status"
        {
            switch AVFoundationMediaPlayerManager.mgr.status
            {
                case .loading:
                    print("Loading")
                    self.avPlayerView.isHidden = true

                    self.playPauseButton.setImage(#imageLiteral(resourceName: "Pause"), for: .normal)
                    self.infoLabel.text = AVFoundationMediaPlayerManager.mgr.loadingMediaItem?.title
                    self.infoLabel.isHidden = false
                    self.errorLabel.text = ""
                    self.errorLabel.isHidden = false
                    self.activitySpinner.startAnimating()

                case .readyToPlay:
                    print("readyToPlay")
                    self.playPauseButton.setImage(#imageLiteral(resourceName: "Pause"), for: .normal)
                    self.activitySpinner.stopAnimating()
                    self.errorLabel.text = ""
                    self.errorLabel.isHidden = false

                    self.avPlayerView.isHidden = false

                case .playing:
                    print("playing")
        
                    self.playPauseButton.setImage(#imageLiteral(resourceName: "Pause"), for: .normal)
                    self.activitySpinner.stopAnimating()
                    self.errorLabel.text = ""
                    self.errorLabel.isHidden = false

                case .paused:
                    print("paused")
                    self.playPauseButton.setImage(#imageLiteral(resourceName: "PlayButton"), for: .normal)
                    self.activitySpinner.stopAnimating()
                    self.errorLabel.text = ""
                    self.errorLabel.isHidden = false

                case .failed:
                    print("failed")
                    self.playPauseButton.setImage(#imageLiteral(resourceName: "PlayButton"), for: .normal)
                    self.activitySpinner.stopAnimating()
                    self.errorLabel.text = "There was a playback error."
                    self.errorLabel.isHidden = false

                case .buffering:
                    print("buffering")
                    self.activitySpinner.startAnimating()
                    self.playPauseButton.setImage(#imageLiteral(resourceName: "Pause"), for: .normal)
                    self.errorLabel.text = ""
                    self.errorLabel.isHidden = false

                case .playedToEnd:
                    self.activitySpinner.stopAnimating()
                    
                    self.playPauseButton.setImage(#imageLiteral(resourceName: "PlayButton"), for: .normal)
                    self.errorLabel.text = ""
                    self.errorLabel.isHidden = false

                case .unknown:
                    print("Unknown")
                    self.errorLabel.isHidden = false
            }
        }
    }
}
