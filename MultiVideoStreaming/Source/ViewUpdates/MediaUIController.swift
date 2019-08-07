//
//  MediaUIController.swift
//  MultiVideoStreaming
//
//  Created by Doug Hill on 8/1/19.
//  Copyright © 2019 doughill. All rights reserved.
//

import UIKit
import MediaPlayer

class MediaUIController: NSObject
{
    var mediaPlayerViewCollection: MediaPlayerUICollection?

    var isSliderChanging = false

    func registerMediaPlayerUICollection(uiCollection: MediaPlayerUICollection)
    {
        self.mediaPlayerViewCollection = uiCollection

        uiCollection.controlsVisibilityToggleButton?.addTarget(self, action: #selector(showHideControlsButtonTapped(_:)), for: .touchUpInside)

        uiCollection.playPauseButton?.addTarget(self, action: #selector(playPauseButtonTapped(_:)), for: .touchUpInside)

        uiCollection.seekTimeSlider?.addTarget(self, action: #selector(sliderDidBeginEditing(_:)), for: .editingDidBegin)

        uiCollection.seekTimeSlider?.addTarget(self, action: #selector(sliderValueChanged(_:)), for: .valueChanged)
        uiCollection.seekTimeSlider?.addTarget(self, action: #selector(sliderTouchUpInside(_:)), for: .touchUpInside)
        uiCollection.seekTimeSlider?.addTarget(self, action: #selector(sliderTouchUpOutside(_:)), for: .touchUpOutside)
        uiCollection.seekTimeSlider?.addTarget(self, action: #selector(sliderTouchCancelled(_:)), for: .touchCancel)
        uiCollection.seekTimeSlider?.addTarget(self, action: #selector(sliderEditingDidEnd(_:)), for: .editingDidEnd)
        uiCollection.seekTimeSlider?.addTarget(self, action: #selector(sliderEditingChanged(_:)), for: .editingChanged)
        uiCollection.seekTimeSlider?.addTarget(self, action: #selector(sliderDidEndOnExit(_:)), for: .editingDidEndOnExit)

        uiCollection.seekTimeSlider?.setThumbImage(#imageLiteral(resourceName: "TimeSeekSliderThumb"), for: .normal)

        uiCollection.infoLabel?.text = MediaPlayerManager.mgr.currentMediaItem?.title
        uiCollection.infoLabel?.isHidden = false
        uiCollection.errorLabel?.text = ""

        if let cButton = MediaPlayerManager.mgr.chromecastPlayer.remoteDevicePickerButton
        {
            uiCollection.remoteButtonsContainerStack?.insertArrangedSubview(cButton, at: uiCollection.remoteButtonsContainerStack?.arrangedSubviews.count ?? 0)
        }

        if let avButton = MediaPlayerManager.mgr.avFoundationPlayer.remoteDevicePickerButton
        {
            uiCollection.remoteButtonsContainerStack?.insertArrangedSubview(avButton, at: uiCollection.remoteButtonsContainerStack?.arrangedSubviews.count ?? 0)
//            uiCollection.remoteButtonsContainerStack?.addArrangedSubview(avButton)
        }

        uiCollection.remoteButtonsContainerStack?.widthAnchor.constraint(greaterThanOrEqualToConstant: 44)
        uiCollection.avPlayerView?.player = MediaPlayerManager.mgr.avFoundationPlayer.player

        self.showControls()
    }

    deinit
    {
        MediaPlayerManager.mgr.stop()
        MediaPlayerManager.mgr.removeObserver(self, forKeyPath: "status")
        MediaPlayerManager.mgr.removeObserver(self, forKeyPath: "currentOffset")
    }

    override init()
    {
        super.init()

        MediaPlayerManager.mgr.addObserver(self, forKeyPath: "status", options: .new, context: nil)
        MediaPlayerManager.mgr.addObserver(self, forKeyPath: "currentOffset", options: .new, context: nil)
    }

    // ============================================================
    // Controls Visibility
    // ============================================================

    var isControlsHidden = false

    var controlsVisibilityTimer: Timer?


    // * showControls
    func showControls()
    {
        print("}}}}} Showing Controls")
        print("Cancelling Timer: \(String(describing: self.controlsVisibilityTimer))")

        self.controlsVisibilityTimer?.invalidate()

        self.controlsVisibilityTimer = nil

        self.mediaPlayerViewCollection?.errorLabel?.isHidden = false
        self.mediaPlayerViewCollection?.infoLabel?.isHidden = false
        self.mediaPlayerViewCollection?.remoteButtonsContainerStack?.isHidden = false
        self.mediaPlayerViewCollection?.playPauseButton?.isHidden = false
        self.mediaPlayerViewCollection?.seekTimeSlider?.isHidden = false
        self.mediaPlayerViewCollection?.backButton?.isHidden = false
        self.mediaPlayerViewCollection?.forwardButton?.isHidden = false
        self.mediaPlayerViewCollection?.toggleFullscreenButton?.isHidden = false

        self.isControlsHidden = false

        self.mediaPlayerViewCollection?.errorLabel?.alpha = 1
        self.mediaPlayerViewCollection?.infoLabel?.alpha = 1
        self.mediaPlayerViewCollection?.remoteButtonsContainerStack?.alpha = 1
        self.mediaPlayerViewCollection?.playPauseButton?.alpha = 1
        self.mediaPlayerViewCollection?.seekTimeSlider?.alpha = 1
        self.mediaPlayerViewCollection?.backButton?.alpha = 1
        self.mediaPlayerViewCollection?.forwardButton?.alpha = 1
        self.mediaPlayerViewCollection?.toggleFullscreenButton?.alpha = 1
    }
    
    // * hideControls
    func hideControls()
    {
        self.controlsVisibilityTimer?.invalidate()

        self.controlsVisibilityTimer = nil

        UIView.animate(withDuration: 0.5,
        animations: {
            self.mediaPlayerViewCollection?.errorLabel?.alpha = 0
            self.mediaPlayerViewCollection?.infoLabel?.alpha = 0
            self.mediaPlayerViewCollection?.remoteButtonsContainerStack?.alpha = 0
            self.mediaPlayerViewCollection?.playPauseButton?.alpha = 0
            self.mediaPlayerViewCollection?.seekTimeSlider?.alpha = 0
            self.mediaPlayerViewCollection?.backButton?.alpha = 0
            self.mediaPlayerViewCollection?.forwardButton?.alpha = 0
//            self.mediaPlayerViewCollection?.activitySpinner?.alpha = 0
            self.mediaPlayerViewCollection?.toggleFullscreenButton?.alpha = 0
        })
        { (completed) in
            self.mediaPlayerViewCollection?.errorLabel?.isHidden = true
            self.mediaPlayerViewCollection?.infoLabel?.isHidden = true
            self.mediaPlayerViewCollection?.remoteButtonsContainerStack?.isHidden = true
            self.mediaPlayerViewCollection?.playPauseButton?.isHidden = true
            self.mediaPlayerViewCollection?.seekTimeSlider?.isHidden = true
            self.mediaPlayerViewCollection?.backButton?.isHidden = true
            self.mediaPlayerViewCollection?.forwardButton?.isHidden = true
            self.mediaPlayerViewCollection?.activitySpinner?.isHidden = true
            self.mediaPlayerViewCollection?.toggleFullscreenButton?.isHidden = true

            self.isControlsHidden = true
        }
    }


    @IBAction func showHideControlsButtonTapped(_ sender: Any)
    {
        print("**$&$&}}}} showHideControlsButtonTapped")

        if isControlsHidden
        {
            self.showControls()
        }
        else
        {
            self.hideControls()
        }
    }

    // * playbackTimeUpdated
    @objc func playbackTimeUpdated( newTime: CMTime)
    {
        let currentTimeSeconds = newTime.seconds
        let durationSeconds = MediaPlayerManager.mgr.duration.seconds
        if durationSeconds > 0 && !self.isSliderChanging && !MediaPlayerManager.mgr.isSeeking
        {
            let fracTimeElapsed = currentTimeSeconds / durationSeconds
            self.mediaPlayerViewCollection?.seekTimeSlider?.value = Float(fracTimeElapsed)
        }
    }

    @IBAction func backButtonTapped(_ sender: Any)
    {
        print("Back button tapped")
    }

    @IBAction func playPauseButtonTapped(_ sender: Any)
    {
        print("^^^^^ playPauseButtonTapped")

        switch MediaPlayerManager.mgr.status
        {
            case .readyToPlay:
                print("* readyToPlay")
//                MediaPlayerManager.mgr.play()
                MediaPlayerManager.mgr.pause()

                self.controlsVisibilityTimer?.invalidate()
                self.controlsVisibilityTimer = nil

                self.showControls()

            case .paused:
                print("* paused")

                MediaPlayerManager.mgr.play()

            case .playing:
                print("* playing")

                MediaPlayerManager.mgr.pause()

                self.controlsVisibilityTimer?.invalidate()
                self.controlsVisibilityTimer = nil

                self.showControls()

            case .failed:
                print("* failed")
                MediaPlayerManager.mgr.play()

            case .loading:
                print("* loading")

                MediaPlayerManager.mgr.play()

            case .unknown:
                print("* unknown")

                MediaPlayerManager.mgr.play()

            case .playedToEnd:
                print("* playedToEnd")

                // When the player is at the end, due to playback finishing
                // normally, starting playback involves
                // - Seek to the beginning
                // - Start playback
                self.mediaPlayerViewCollection?.seekTimeSlider?.value = 0
                self.mediaPlayerViewCollection?.playPauseButton?.setImage(#imageLiteral(resourceName: "Pause"), for: .normal)

                MediaPlayerManager.mgr.seek(to: CMTime.zero, playAfterSeek: true)
                { (finished) in
                    MediaPlayerManager.mgr.play()
                }

            case .buffering:
                print("* buffering")

                MediaPlayerManager.mgr.pause()

            case .idle:
                print("* idle")

                print("Player is idle.")
        }
    }

    @IBAction func forwardButtonTapped(_ sender: Any)
    {
    }

    //

    @IBAction func sliderDidBeginEditing(_ sender: Any)
    {
        print("sliderDidBeginEditing")
    }

    @IBAction func sliderValueChanged(_ sender: Any)
    {
        print("sliderValueChanged")

        self.isSliderChanging = true

        self.controlsVisibilityTimer?.invalidate()
        self.controlsVisibilityTimer = nil

        print("***** Slider >> Value Changed\nNew Value: \(self.mediaPlayerViewCollection?.seekTimeSlider?.value)")
        let currentSliderValue = Double(self.mediaPlayerViewCollection?.seekTimeSlider?.value ?? 0)
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
//            MediaPlayerManager.mgr.pause()

            MediaPlayerManager.mgr.seek(
                to: CMTime( seconds: seekTimeSec,
                            preferredTimescale: CMTimeScale(1) ),
                playAfterSeek: false
            )
            { (finished) in
                print("Seeked to \(seekTimeSec): Finished = \(finished)")
            }
        }
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
        print("***** Slider >> Touch Up Inside\nNew Value: \(self.mediaPlayerViewCollection?.seekTimeSlider?.value)")
        let currentSliderValue = Double(self.mediaPlayerViewCollection?.seekTimeSlider?.value ?? 0)
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
//            MediaPlayerManager.mgr.pause()

            MediaPlayerManager.mgr.seek(
                to: CMTime( seconds: seekTimeSec,
                            preferredTimescale: CMTimeScale(1) ),
                playAfterSeek: true
            )
            { (finished) in
                print("Seeked to \(seekTimeSec): Finished = \(finished)")

                if seekTimeSec != duration.seconds && finished
                {
                    MediaPlayerManager.mgr.play()
                }

                self.isSliderChanging = false
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

                if MediaPlayerManager.mgr.status == .playing &&
                   self.isSliderChanging == false &&
                   self.isControlsHidden == false &&
                   self.controlsVisibilityTimer == nil
                {
                    let randomID = UUID.init()
                    print(">>>>>> After playback has started, auto-hide controls.")
                    print("Timer ID: \(randomID)")

                    self.controlsVisibilityTimer = Timer.scheduledTimer(withTimeInterval: 2, repeats: false, block:
                    { (timer: Timer) in
                        print(">>>>>> Auto-hide timer has fired.")
                        print("Timer: \(timer)")
                        print("Timer ID: \(randomID)")
                        print("Is Timer Valid? \(timer.isValid)")

                        if timer.isValid
                        {
                            self.hideControls()
                        }

                        self.controlsVisibilityTimer = nil
                    })
                }
            }
        }

        print("**************************************")
    }

    func playerStatusUpdated( status: PlaybackStatus )
    {
        switch status
        {
            case .loading:
                print("Loading")
                self.mediaPlayerViewCollection?.avPlayerView?.isHidden = true

                self.mediaPlayerViewCollection?.playPauseButton?.setImage(#imageLiteral(resourceName: "Pause"), for: .normal)
                self.mediaPlayerViewCollection?.infoLabel?.text = MediaPlayerManager.mgr.loadingMediaItem?.title
                self.mediaPlayerViewCollection?.infoLabel?.isHidden = false
                self.mediaPlayerViewCollection?.errorLabel?.text = ""
                self.mediaPlayerViewCollection?.errorLabel?.isHidden = true
                self.mediaPlayerViewCollection?.activitySpinner?.startAnimating()
                self.mediaPlayerViewCollection?.activitySpinner?.isHidden = false

                self.showControls()

            case .readyToPlay:
                print("readyToPlay")
                self.mediaPlayerViewCollection?.playPauseButton?.setImage(#imageLiteral(resourceName: "Pause"), for: .normal)
                self.mediaPlayerViewCollection?.activitySpinner?.stopAnimating()
                self.mediaPlayerViewCollection?.activitySpinner?.isHidden = true
                self.mediaPlayerViewCollection?.errorLabel?.text = ""
                self.mediaPlayerViewCollection?.errorLabel?.isHidden = true

                self.mediaPlayerViewCollection?.avPlayerView?.isHidden = false

                self.showControls()

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
                    self.mediaPlayerViewCollection?.playPauseButton?.setImage(#imageLiteral(resourceName: "PlayButton"), for: .normal)
                }
                else
                {
                    self.mediaPlayerViewCollection?.playPauseButton?.setImage(#imageLiteral(resourceName: "Pause"), for: .normal)
                }

                self.mediaPlayerViewCollection?.activitySpinner?.stopAnimating()
                self.mediaPlayerViewCollection?.activitySpinner?.isHidden = true
                self.mediaPlayerViewCollection?.errorLabel?.text = ""
                self.mediaPlayerViewCollection?.errorLabel?.isHidden = true

                if self.isControlsHidden == false && !self.isSliderChanging
                {
                    self.controlsVisibilityTimer?.invalidate()

                    print("++++++++ Create a Controls auto-hide timer:")

                    self.controlsVisibilityTimer = Timer.scheduledTimer(withTimeInterval: 2, repeats: false, block:
                    { (timer: Timer) in
                        print("++++++++ Fired timer: \(timer)")
                        print("And it is valid: \(timer.isValid)")

                        if timer.isValid
                        {
                            self.controlsVisibilityTimer = nil
                            self.hideControls()
                        }
                    })

                    print("++++++++ Timer: \(self.controlsVisibilityTimer)")
                }

            case .paused:
                print("paused")

                if self.isSliderChanging == false
                {
                    self.mediaPlayerViewCollection?.playPauseButton?.setImage(#imageLiteral(resourceName: "PlayButton"), for: .normal)
                }

                self.mediaPlayerViewCollection?.activitySpinner?.stopAnimating()
                self.mediaPlayerViewCollection?.activitySpinner?.isHidden = true

                self.mediaPlayerViewCollection?.errorLabel?.text = ""
                self.mediaPlayerViewCollection?.errorLabel?.isHidden = true

                self.showControls()

            case .failed:
                print("failed")
                self.mediaPlayerViewCollection?.playPauseButton?.setImage(#imageLiteral(resourceName: "PlayButton"), for: .normal)
                self.mediaPlayerViewCollection?.activitySpinner?.stopAnimating()
                self.mediaPlayerViewCollection?.activitySpinner?.isHidden = true
                self.mediaPlayerViewCollection?.errorLabel?.text = "There was a playback error."
                self.mediaPlayerViewCollection?.errorLabel?.isHidden = false

                self.showControls()

            case .buffering:
                print("buffering")
                self.mediaPlayerViewCollection?.activitySpinner?.startAnimating()
                self.mediaPlayerViewCollection?.activitySpinner?.isHidden = false

                if self.isSliderChanging == false
                {
                    self.mediaPlayerViewCollection?.playPauseButton?.setImage(#imageLiteral(resourceName: "Pause"), for: .normal)
                }

                self.mediaPlayerViewCollection?.errorLabel?.text = ""
                self.mediaPlayerViewCollection?.errorLabel?.isHidden = true

            case .playedToEnd:
                self.mediaPlayerViewCollection?.activitySpinner?.stopAnimating()
                self.mediaPlayerViewCollection?.activitySpinner?.isHidden = true

                self.mediaPlayerViewCollection?.playPauseButton?.setImage(#imageLiteral(resourceName: "PlayButton"), for: .normal)
                self.mediaPlayerViewCollection?.errorLabel?.text = ""
                self.mediaPlayerViewCollection?.errorLabel?.isHidden = true

                self.showControls()

            case .idle:
                self.mediaPlayerViewCollection?.playPauseButton?.setImage(#imageLiteral(resourceName: "PlayButton"), for: .normal)
                self.mediaPlayerViewCollection?.errorLabel?.text = ""
                self.mediaPlayerViewCollection?.errorLabel?.isHidden = true

                self.showControls()

            case .unknown:
                print("Unknown")
                self.mediaPlayerViewCollection?.errorLabel?.isHidden = false
        }
    }
}
