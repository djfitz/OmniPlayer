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
    var chromecastButton: GCKUIMultistateButton?
    @IBOutlet weak var airplayButton: MPVolumeView!

    @IBOutlet weak var avPlayerView: AVPlayerView!
    
    deinit
    {
        AVFoundationMediaPlayerManager.mgr.removeObserver(self, forKeyPath: "status")
        AVFoundationMediaPlayerManager.mgr.removeObserver(self, forKeyPath: "currentTime")
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.init("PlaybackTimeObserver"), object: nil)
    }

    override func viewDidLoad()
    {
        super.viewDidLoad()

        self.avPlayerView.player = AVFoundationMediaPlayerManager.mgr.player

        AVFoundationMediaPlayerManager.mgr.addObserver(self, forKeyPath: "status", options: .new, context: nil)
        AVFoundationMediaPlayerManager.mgr.addObserver(self, forKeyPath: "currentTime", options: .new, context: nil)

        self.seekTimeSlider.setThumbImage(UIImage(named: "TimeSeekSliderThumb"), for: .normal)
        self.seekTimeSlider.setThumbImage(UIImage(named: "TimeSeekSliderThumb"), for: .selected)
        self.seekTimeSlider.setThumbImage(UIImage(named: "TimeSeekSliderThumb"), for: .highlighted)

        self.infoLabel.text = AVFoundationMediaPlayerManager.mgr.currentMediaItem?.title
        self.infoLabel.isHidden = false
        self.errorLabel.text = ""

        if let cButton = ChromecastManager.mgr.remoteDevicePickerButton
        {
            self.remoteButtonsContainerStack.addArrangedSubview(cButton)
        }
    }

    @objc func playbackTimeUpdated( newTime: CMTime)
    {
        let currentTimeSeconds = newTime.seconds
        let durationSeconds = AVFoundationMediaPlayerManager.mgr.duration.seconds
        if durationSeconds > 0 && !self.isSliderChanging && !AVFoundationMediaPlayerManager.mgr.isSeeking
        {
            let fracTimeElapsed = currentTimeSeconds / durationSeconds
            self.seekTimeSlider.value = Float(fracTimeElapsed)
        }
    }

    @IBAction func backButtonTapped(_ sender: Any)
    {
        print("Back button tapped")
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
                // When the player is at the end, due to playback finishing
                // normally, starting playback involves
                // - Seek to the beginning
                // - Start playback
                self.seekTimeSlider.value = 0
                self.playPauseButton.setImage(#imageLiteral(resourceName: "Pause"), for: .normal)

                AVFoundationMediaPlayerManager.mgr.seek(to: CMTime.zero)
                { (cancelled) in
                    AVFoundationMediaPlayerManager.mgr.play()
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
        print("sliderValueChanged")
        self.isSliderChanging = true
    }
    
    @IBAction func sliderEditingChanged(_ sender: Any)
    {
        print("sliderEditingChanged")
        self.isSliderChanging = true
    }
    
    @IBAction func sliderTouchCancelled(_ sender: Any)
    {
        print("sliderTouchCancelled")
        self.isSliderChanging = false
    }
    
    @IBAction func sliderEditingDidEnd(_ sender: Any)
    {
        print("sliderEditingDidEnd")
        self.isSliderChanging = false
    }
    
    @IBAction func sliderDidEndOnExit(_ sender: Any)
    {
        print("sliderDidEndOnExit")
        self.isSliderChanging = false
    }

    @IBAction func sliderTouchUpInside(_ sender: Any)
    {
        print("***** Slider >> Touch Up Inside\nNew Value: \(self.seekTimeSlider!.value)")
        let currentSliderValue = Double(self.seekTimeSlider!.value)
        let duration = AVFoundationMediaPlayerManager.mgr.duration
        let seekTimeSec = currentSliderValue * duration.seconds

        if seekTimeSec == duration.seconds
        {
            print("***** Seeking to the end.")
        }

        AVFoundationMediaPlayerManager.mgr.pause()

        AVFoundationMediaPlayerManager.mgr.seek(
            to: CMTime( seconds: seekTimeSec,
                        preferredTimescale: CMTimeScale(1) )
        )
        { (cancelled) in
            print("Seeked to \(seekTimeSec): Cancelled = \(cancelled)")

            self.isSliderChanging = false

            if seekTimeSec != duration.seconds && !cancelled
            {
                AVFoundationMediaPlayerManager.mgr.play()
            }
        }
    }

    //
    
    
    // * observeValue(forKeyPath…)
    @objc override func observeValue(forKeyPath keyPath: String?,
                                     of object: Any?,
                                     change: [NSKeyValueChangeKey : Any]?,
                                     context: UnsafeMutableRawPointer?)
    {
        print("\n**************************************")
        print("Observed Value change: \(keyPath!)")
        print("Object: \(object!)")
        print("Kind: \(change![NSKeyValueChangeKey.kindKey]!)")
        print("New Value: \(change![NSKeyValueChangeKey.newKey]!)")

        if keyPath == "status"
        {
            self.playerStatusUpdated(status: AVFoundationMediaPlayerManager.mgr.status)
        }
        else if keyPath == "currentTime"
        {
            if let newCurrentTime = change?[NSKeyValueChangeKey.newKey] as? CMTime
            {
                self.playbackTimeUpdated(newTime: newCurrentTime)
            }
        }

        print("**************************************")
    }

    func playerCurrentTimeUpdated( time: CMTime)
    {
        
    }

    func playerStatusUpdated( status: AVFoundationMediaPlayerManager.Status )
    {
        switch status
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

                let currentTimeSec = AVFoundationMediaPlayerManager.mgr.currentTime.seconds
                let durationSec = AVFoundationMediaPlayerManager.mgr.duration.seconds

                let currentTimeRoundedWholeSec = currentTimeSec.rounded(.down)
                let currentTimeFrac = currentTimeSec - currentTimeRoundedWholeSec
                let currentTimeFracRoundedFrac = (currentTimeFrac * 100).rounded(.down) / 100
                let currentTimeRoundedSec = currentTimeRoundedWholeSec + currentTimeFracRoundedFrac
                
                let durationRoundedWholeSec = durationSec.rounded(.down)
                let durationFrac = durationSec - durationRoundedWholeSec
                let durationFracRoundedFrac = (durationFrac * 100).rounded(.down) / 100
                let durationRoundedSec = durationRoundedWholeSec + durationFracRoundedFrac

                print("**** Current Time =  \(currentTimeSec) Rounded: \(currentTimeRoundedSec)")
                print("**** Duration = \(durationSec) rounded to \(durationRoundedSec)")

                if durationRoundedSec <= currentTimeRoundedSec
                {
                    self.playButton.setImage(#imageLiteral(resourceName: "PlayButton"), for: .normal)
                }
                else
                {
                    self.playPauseButton.setImage(#imageLiteral(resourceName: "Pause"), for: .normal)
                }

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
