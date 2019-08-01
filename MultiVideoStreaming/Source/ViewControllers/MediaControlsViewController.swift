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
        MediaPlayerManager.mgr.stop()
        MediaPlayerManager.mgr.removeObserver(self, forKeyPath: "status")
        MediaPlayerManager.mgr.removeObserver(self, forKeyPath: "currentOffset")
    }

    override func viewDidLoad()
    {
        super.viewDidLoad()

        self.avPlayerView.player = MediaPlayerManager.mgr.avFoundationPlayer.player

        MediaPlayerManager.mgr.addObserver(self, forKeyPath: "status", options: .new, context: nil)
        MediaPlayerManager.mgr.addObserver(self, forKeyPath: "currentOffset", options: .new, context: nil)

        self.seekTimeSlider.setThumbImage(UIImage(named: "TimeSeekSliderThumb"), for: .normal)
        self.seekTimeSlider.setThumbImage(UIImage(named: "TimeSeekSliderThumb"), for: .selected)
        self.seekTimeSlider.setThumbImage(UIImage(named: "TimeSeekSliderThumb"), for: .highlighted)

        self.infoLabel.text = MediaPlayerManager.mgr.currentMediaItem?.title
        self.infoLabel.isHidden = false
        self.errorLabel.text = ""

        if let cButton = MediaPlayerManager.mgr.chromecastPlayer.remoteDevicePickerButton
        {
//            self.remoteButtonsContainerStack.backgroundColor = .red
//            cButton.backgroundColor = .green
            self.remoteButtonsContainerStack.addArrangedSubview(cButton)
            cButton.isHidden = false
        }
    }

    @objc func playbackTimeUpdated( newTime: CMTime)
    {
        let currentTimeSeconds = newTime.seconds
        let durationSeconds = MediaPlayerManager.mgr.duration.seconds
        if durationSeconds > 0 && !self.isSliderChanging && !MediaPlayerManager.mgr.isSeeking
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
        switch MediaPlayerManager.mgr.status
        {
            case .readyToPlay:
                MediaPlayerManager.mgr.play()

            case .paused:
                MediaPlayerManager.mgr.play()

            case .playing:
                MediaPlayerManager.mgr.pause()

            case .failed:
                MediaPlayerManager.mgr.play()

            case .loading:
                MediaPlayerManager.mgr.play()

            case .unknown:
                MediaPlayerManager.mgr.play()

            case .playedToEnd:
                // When the player is at the end, due to playback finishing
                // normally, starting playback involves
                // - Seek to the beginning
                // - Start playback
                self.seekTimeSlider.value = 0
                self.playPauseButton.setImage(#imageLiteral(resourceName: "Pause"), for: .normal)

                MediaPlayerManager.mgr.seek(to: CMTime.zero)
                { (cancelled) in
                    MediaPlayerManager.mgr.play()
                }

            case .buffering:
                MediaPlayerManager.mgr.pause()

            case .idle:
                print("Player is idle.")
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

    @IBAction func sliderTouchUpOutside(_ sender: Any)
    {
        self.sliderTouchUpInside(sender)
    }

    @IBAction func sliderTouchUpInside(_ sender: Any)
    {
        print("***** Slider >> Touch Up Inside\nNew Value: \(self.seekTimeSlider!.value)")
        let currentSliderValue = Double(self.seekTimeSlider!.value)
        let duration = MediaPlayerManager.mgr.duration
        let seekTimeSec = currentSliderValue * duration.seconds

        if seekTimeSec == duration.seconds
        {
            print("***** Seeking to the end.")
        }

        if MediaPlayerManager.mgr.status == .playedToEnd
        {
            if let mediaItem = MediaPlayerManager.mgr.currentMediaItem
            {
                MediaPlayerManager.mgr.load(mediaItem: mediaItem, startingAt: CMTime.init(seconds: seekTimeSec, preferredTimescale: 1))
            }
        }
        else
        {
            MediaPlayerManager.mgr.pause()

            MediaPlayerManager.mgr.seek(
                to: CMTime( seconds: seekTimeSec,
                            preferredTimescale: CMTimeScale(1) )
            )
            { (cancelled) in
                print("Seeked to \(seekTimeSec): Cancelled = \(cancelled)")

                self.isSliderChanging = false

                if seekTimeSec != duration.seconds && !cancelled
                {
                    MediaPlayerManager.mgr.play()
                }
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
            self.playerStatusUpdated(status: MediaPlayerManager.mgr.status)
        }
        else if keyPath == "currentOffset"
        {
            if let newValue = change?[NSKeyValueChangeKey.newKey] as? CMTime
            {
                print("New Current Offset: \(newValue.seconds)")
            }

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

    func playerStatusUpdated( status: PlaybackStatus )
    {
        switch status
        {
            case .loading:
                print("Loading")
                self.avPlayerView.isHidden = true

                self.playPauseButton.setImage(#imageLiteral(resourceName: "Pause"), for: .normal)
                self.infoLabel.text = MediaPlayerManager.mgr.loadingMediaItem?.title
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

                let currentTimeSec = MediaPlayerManager.mgr.currentOffset.seconds
                let durationSec = MediaPlayerManager.mgr.duration.seconds

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

            case .idle:
                self.playPauseButton.setImage(#imageLiteral(resourceName: "PlayButton"), for: .normal)
                self.errorLabel.text = ""
                self.errorLabel.isHidden = false

            case .unknown:
                print("Unknown")
                self.errorLabel.isHidden = false
        }
    }
}
