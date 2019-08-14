//
//  MediaUIController.swift
//  MultiVideoStreaming
//
//  Created by Doug Hill on 8/1/19.
//  Copyright © 2019 doughill. All rights reserved.
//

import UIKit
import MediaPlayer

@objc public class MediaUIController: NSObject
{
    static var showPlayerUIUpdateLogMessages = false

    func log(msg: String)
    {
        if MediaUIController.showPlayerUIUpdateLogMessages
        {
            print("\(msg)")
        }
    }

    var mediaPlayerViewCollection: MediaPlayerUICollection?

    var isSliderChanging = false

    var lastSeekTime = CMTime.invalid

    func registerMediaPlayerUICollection(uiCollection: MediaPlayerUICollection)
    {
        self.mediaPlayerViewCollection = uiCollection

        uiCollection.controlsVisibilityToggleButton?.addTarget(self, action: #selector(showHideControlsButtonTapped(_:)), for: .touchUpInside)

        uiCollection.playPauseButton?.addTarget(self, action: #selector(playPauseButtonTapped(_:)), for: .touchUpInside)

        uiCollection.seekTimeSlider?.addTarget(self, action: #selector(sliderDidBeginEditing(_:)), for: .editingDidBegin)
        uiCollection.seekTimeSlider?.addTarget(self, action: #selector(sliderTouchDown(_:)), for: .touchDown)
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

        MediaUIController.showPlayerUIUpdateLogMessages = true

        MediaPlayerManager.mgr.addObserver(self, forKeyPath: "status", options: .new, context: nil)
        MediaPlayerManager.mgr.addObserver(self, forKeyPath: "currentOffset", options: .new, context: nil)
    }

    // ============================================================
    // Controls Visibility
    // ============================================================

    var isControlsHidden = false

    var controlsVisibilityTimer: Timer?

    var shouldAutoHideControls = false

    // * showControls
    func showControls()
    {
//        log(msg: "}}}}} Showing Controls")
//        log(msg: "Cancelling Timer: \(String(describing: self.controlsVisibilityTimer))")

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
        self.mediaPlayerViewCollection?.timeElapsedLabel?.isHidden = false
        self.mediaPlayerViewCollection?.startRemainingTimeComboLabel?.isHidden = false

        self.isControlsHidden = false

        self.mediaPlayerViewCollection?.errorLabel?.alpha = 1
        self.mediaPlayerViewCollection?.infoLabel?.alpha = 1
        self.mediaPlayerViewCollection?.remoteButtonsContainerStack?.alpha = 1
        self.mediaPlayerViewCollection?.playPauseButton?.alpha = 1
        self.mediaPlayerViewCollection?.seekTimeSlider?.alpha = 1
        self.mediaPlayerViewCollection?.backButton?.alpha = 1
        self.mediaPlayerViewCollection?.forwardButton?.alpha = 1
        self.mediaPlayerViewCollection?.toggleFullscreenButton?.alpha = 1
        self.mediaPlayerViewCollection?.timeElapsedLabel?.alpha = 1
        self.mediaPlayerViewCollection?.startRemainingTimeComboLabel?.alpha = 1
    }
    
    // * hideControls
    func hideControls()
    {
        self.controlsVisibilityTimer?.invalidate()

        self.controlsVisibilityTimer = nil

        UIView.animate(withDuration: 0.5,
        animations:
        {
            self.mediaPlayerViewCollection?.errorLabel?.alpha = 0
            self.mediaPlayerViewCollection?.infoLabel?.alpha = 0
            self.mediaPlayerViewCollection?.remoteButtonsContainerStack?.alpha = 0
            self.mediaPlayerViewCollection?.playPauseButton?.alpha = 0
            self.mediaPlayerViewCollection?.seekTimeSlider?.alpha = 0
            self.mediaPlayerViewCollection?.backButton?.alpha = 0
            self.mediaPlayerViewCollection?.forwardButton?.alpha = 0
//            self.mediaPlayerViewCollection?.activitySpinner?.alpha = 0
            self.mediaPlayerViewCollection?.toggleFullscreenButton?.alpha = 0
            self.mediaPlayerViewCollection?.timeElapsedLabel?.alpha = 0
            self.mediaPlayerViewCollection?.startRemainingTimeComboLabel?.alpha = 0
        })
        { (completed) in
            self.mediaPlayerViewCollection?.errorLabel?.isHidden = true
            self.mediaPlayerViewCollection?.infoLabel?.isHidden = true
            self.mediaPlayerViewCollection?.remoteButtonsContainerStack?.isHidden = true
            self.mediaPlayerViewCollection?.playPauseButton?.isHidden = true
            self.mediaPlayerViewCollection?.seekTimeSlider?.isHidden = true
            self.mediaPlayerViewCollection?.backButton?.isHidden = true
            self.mediaPlayerViewCollection?.forwardButton?.isHidden = true
//            self.mediaPlayerViewCollection?.activitySpinner?.alpha = 0
            self.mediaPlayerViewCollection?.toggleFullscreenButton?.isHidden = true
            self.mediaPlayerViewCollection?.timeElapsedLabel?.isHidden = true
            self.mediaPlayerViewCollection?.startRemainingTimeComboLabel?.isHidden = true

            self.isControlsHidden = true
        }
    }


    @IBAction func showHideControlsButtonTapped(_ sender: Any)
    {
        log( msg:"**$&$&}}}} showHideControlsButtonTapped")

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
        let duration = MediaPlayerManager.mgr.duration
        let currentTimeSeconds = newTime.seconds
        let durationSeconds = duration.seconds
        if durationSeconds > 0 && !self.isSliderChanging && !MediaPlayerManager.mgr.isSeeking
        {
            let fracTimeElapsed = currentTimeSeconds / durationSeconds
            self.mediaPlayerViewCollection?.seekTimeSlider?.value = Float(fracTimeElapsed)

            self.updateTimeReadout(for: newTime, duration: duration)
        }
    }

    /*!
        Returns a formatted string of the form:
        <hours>:<minutes>:<seconds>
    */
    func hmsTimeString(for time:CMTime) -> String
    {
        if time.isValid
        {
            let timeSeconds =
                time.seconds >= 0 ?
                time.seconds : 0

            var secondsDigitsString = "00"
            var minutesDigitsString = "00"

            var timeFracMinute = timeSeconds.remainder(dividingBy: 60)

            if timeFracMinute < 0
            {
                timeFracMinute = 60 + timeFracMinute
            }

            let secsDigitsValue = abs(timeFracMinute.rounded(FloatingPointRoundingRule.towardZero))

            secondsDigitsString = Int(secsDigitsValue).description

//            self.log(msg: "Seconds Time Display: \(secondsDigitsString)")

            if timeFracMinute < 10
            {
                secondsDigitsString = "0" + secondsDigitsString
            }

            let fracMinutes = timeSeconds / 60

            if fracMinutes >= 1
            {
                var currentTimeFracHour = fracMinutes.remainder(dividingBy: (60))

                if currentTimeFracHour < 0
                {
                    currentTimeFracHour = 60 + currentTimeFracHour
                }

                let minsDigitValue = abs(currentTimeFracHour.rounded(FloatingPointRoundingRule.towardZero))

                minutesDigitsString = Int(minsDigitValue).description

                if minsDigitValue < 10
                {
                    minutesDigitsString = "0" + minutesDigitsString
                }

//                self.log(msg: "Minute Time Display: \(minutesDigitsString)")
            }

            let labelStr = minutesDigitsString + ":" + secondsDigitsString

            return labelStr
        }
        else
        {
            return "--:--"
        }
    }

    func updateTimeReadout(for currentMediaPlaybackOffset: CMTime, duration: CMTime)
    {
        self.mediaPlayerViewCollection?.startRemainingTimeComboLabel?.text = self.hmsTimeString(for: currentMediaPlaybackOffset)
        self.mediaPlayerViewCollection?.timeElapsedLabel?.text = self.hmsTimeString(for: duration)
    }

    @IBAction func backButtonTapped(_ sender: Any)
    {
        log( msg:"Back button tapped")
    }

    @IBAction func playPauseButtonTapped(_ sender: Any)
    {
        log( msg:"^^^^^ playPauseButtonTapped")

        switch MediaPlayerManager.mgr.status
        {
            case .readyToPlay:
                self.log( msg:"* readyToPlay")

                MediaPlayerManager.mgr.pause()

                self.controlsVisibilityTimer?.invalidate()
                self.controlsVisibilityTimer = nil

                self.showControls()

            case .paused:
                self.log( msg:"* paused")

                MediaPlayerManager.mgr.play()

            case .playing:
                self.log( msg:"* playing")

                MediaPlayerManager.mgr.pause()

                self.controlsVisibilityTimer?.invalidate()
                self.controlsVisibilityTimer = nil

                self.showControls()

            case .failed:
                self.log( msg:"* failed")
                MediaPlayerManager.mgr.play()

            case .loading:
                self.log( msg:"* loading")

                MediaPlayerManager.mgr.play()

            case .unknown:
                self.log( msg:"* unknown")

                MediaPlayerManager.mgr.play()

            case .playedToEnd:
                self.log( msg:"* playedToEnd")

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
                self.log( msg:"* buffering")

                MediaPlayerManager.mgr.pause()

            case .idle:
                self.log( msg:"* idle")
        }
    }

    @IBAction func forwardButtonTapped(_ sender: Any)
    {
    }

    //

    @IBAction func sliderTouchDown(_ sender: Any)
    {
        self.log( msg:"sliderTouchDown")

        self.lastSeekTime = CMTime.invalid

        self.controlsVisibilityTimer?.invalidate()
        self.controlsVisibilityTimer = nil

        self.isSliderChanging = true
    }

    @IBAction func sliderDidBeginEditing(_ sender: Any)
    {
        self.log( msg:"sliderDidBeginEditing")

        self.controlsVisibilityTimer?.invalidate()
        self.controlsVisibilityTimer = nil

        self.isSliderChanging = true
    }

    @IBAction func sliderValueChanged(_ sender: Any)
    {
        self.log( msg:"sliderValueChanged")

        self.log( msg:"\n***** Slider >> Value Changed\nNew Value: \(String(describing: self.mediaPlayerViewCollection?.seekTimeSlider?.value))")

        if let slider = sender as? UISlider
        {
            let currentSliderValue = slider.value
            let duration = MediaPlayerManager.mgr.duration
            let seekTimeSec = Double(currentSliderValue) * duration.seconds

            self.mediaPlayerViewCollection?.startRemainingTimeComboLabel?.text = self.hmsTimeString(for: CMTime(seconds: seekTimeSec, preferredTimescale: 1))
//        self.seek(to: CMTime(seconds: seekTimeSec, preferredTimescale: 1))
        }
    }

    @IBAction func sliderEditingChanged(_ sender: Any)
    {
        self.log( msg:"sliderEditingChanged")
        self.isSliderChanging = true
    }

    @IBAction func sliderTouchCancelled(_ sender: Any)
    {
        self.log( msg:"sliderTouchCancelled")
        self.isSliderChanging = false
    }

    @IBAction func sliderEditingDidEnd(_ sender: Any)
    {
        self.log( msg:"sliderEditingDidEnd")
        self.isSliderChanging = false
    }

    @IBAction func sliderDidEndOnExit(_ sender: Any)
    {
        self.log( msg:"sliderDidEndOnExit")
        self.isSliderChanging = false
    }

    @IBAction func sliderTouchUpOutside(_ sender: Any)
    {
        self.sliderTouchUpInside(sender)
    }

    @IBAction func sliderTouchUpInside(_ sender: Any)
    {
        self.log( msg:"\n***** Slider >> Touch Up Inside\nNew Value: \(String( describing: self.mediaPlayerViewCollection?.seekTimeSlider?.value))\n")

        self.log( msg:"\n***** Slider >> Value Changed\nNew Value: \(String(describing: self.mediaPlayerViewCollection?.seekTimeSlider?.value))")
        self.log( msg:"***** Slider is Changing: \(self.isSliderChanging)")
        let currentSliderValue = Double(self.mediaPlayerViewCollection?.seekTimeSlider?.value ?? 0)
        let duration = MediaPlayerManager.mgr.duration
        let seekTimeSec = currentSliderValue * duration.seconds

        self.seek(to: CMTime(seconds: seekTimeSec, preferredTimescale: 1))
    }

    func seek( to newTime:CMTime)
    {
        if self.isSliderChanging
        {
            let duration = MediaPlayerManager.mgr.duration

            if newTime.seconds == duration.seconds
            {
                self.log( msg:"***** Seeking to the end.")
            }

            if MediaPlayerManager.mgr.status == .playedToEnd
            {
                if let mediaItem = MediaPlayerManager.mgr.currentMediaItem
                {
                    DispatchQueue.main.async
                    {
                        MediaPlayerManager.mgr.load(mediaItem: mediaItem, startingAt: newTime)
                        self.updateTimeReadout(for: newTime, duration: MediaPlayerManager.mgr.duration)
                        self.isSliderChanging = false
                    }
                }
            }
            else
            {
                if newTime.isValid && newTime != self.lastSeekTime
                {
                    self.lastSeekTime = newTime

                    MediaPlayerManager.mgr.seek( to: newTime, playAfterSeek: true )
                    { (finished) in
                        self.isSliderChanging = false
                        self.log( msg:"Seeked to \(newTime.seconds): Finished = \(finished)")
                    }
                }
                else
                {
                    self.log( msg:"\n>$>$>$>$>$>$> >> Skipping redundant seek to \(newTime)")
                }
            }
        }
    }

    //

    // * observeValue(forKeyPath…)
    @objc public override func observeValue(forKeyPath keyPath: String?,
                                     of object: Any?,
                                     change: [NSKeyValueChangeKey : Any]?,
                                     context: UnsafeMutableRawPointer?)
    {
//        self.log( msg:"\n**************************************")
//        self.log( msg:"Observed Value change: \(keyPath!)")
//        self.log( msg:"Object: \(object!)")
//        self.log( msg:"Kind: \(change![NSKeyValueChangeKey.kindKey]!)")
//        self.log( msg:"New Value: \(change![NSKeyValueChangeKey.newKey]!)")

        if keyPath == "status"
        {
            self.playerStatusUpdated(status: MediaPlayerManager.mgr.status)
        }
        else if keyPath == "currentOffset"
        {
//            if let newValue = change?[NSKeyValueChangeKey.newKey] as? CMTime
//            {
//                self.log( msg:"New Current Offset: \(newValue.seconds)")
//            }

            if let newCurrentTime = change?[NSKeyValueChangeKey.newKey] as? CMTime
            {
                if self.isSliderChanging == false &&
                   self.controlsVisibilityTimer == nil
                {
//                    let randomID = UUID.init()
//                    self.log( msg:">>>>>> After playback has started, auto-hide controls.")
//                    self.log( msg:"Timer ID: \(randomID)")

                    self.playbackTimeUpdated(newTime: newCurrentTime)

                    if self.shouldAutoHideControls
                    {
                        self.controlsVisibilityTimer =
                        Timer.scheduledTimer(
                            withTimeInterval: 1.5,
                            repeats: false, block:
                            { (timer: Timer) in
//                                self.log( msg:">>>>>> Auto-hide timer has fired.")
//                                self.log( msg:"Timer: \(timer)")
//                                self.log( msg:"Timer ID: \(randomID)")
//                                self.log( msg:"Is Timer Valid? \(timer.isValid)")

                                if timer.isValid
                                {
                                    self.hideControls()
                                }

                                self.controlsVisibilityTimer = nil
                            }
                        )
                    }
                }
            }
        }

//        self.log( msg:"**************************************")
    }

    func playerStatusUpdated( status: PlaybackStatus )
    {
        switch status
        {
            case .loading:
                self.log( msg:"Loading")

                self.mediaPlayerViewCollection?.avPlayerView?.isHidden = true

                self.mediaPlayerViewCollection?.playPauseButton?.setImage(#imageLiteral(resourceName: "Pause"), for: .normal)
                self.mediaPlayerViewCollection?.infoLabel?.text = MediaPlayerManager.mgr.loadingMediaItem?.title
                self.mediaPlayerViewCollection?.infoLabel?.isHidden = false
                self.mediaPlayerViewCollection?.errorLabel?.text = ""
                self.mediaPlayerViewCollection?.errorLabel?.isHidden = true
                self.mediaPlayerViewCollection?.activitySpinner?.startAnimating()
                self.mediaPlayerViewCollection?.activitySpinner?.isHidden = false
                self.mediaPlayerViewCollection?.activitySpinner?.alpha = 1

                self.showControls()

            case .readyToPlay:
                self.log( msg:"readyToPlay")
                self.mediaPlayerViewCollection?.playPauseButton?.setImage(#imageLiteral(resourceName: "Pause"), for: .normal)
                self.mediaPlayerViewCollection?.activitySpinner?.stopAnimating()
                self.mediaPlayerViewCollection?.activitySpinner?.alpha = 0
//                self.mediaPlayerViewCollection?.activitySpinner?.isHidden = true
                self.mediaPlayerViewCollection?.errorLabel?.text = ""
                self.mediaPlayerViewCollection?.errorLabel?.isHidden = true

                self.mediaPlayerViewCollection?.avPlayerView?.isHidden = false

                self.showControls()

            case .playing:
                self.log( msg:"playing")

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

                self.log( msg:"**** Current Time =  \(currentTimeSec) Rounded: \(currentTimeRoundedSec)")
                self.log( msg:"**** Duration = \(durationSec) rounded to \(durationRoundedSec)")

                if durationRoundedSec <= currentTimeRoundedSec
                {
                    self.mediaPlayerViewCollection?.playPauseButton?.setImage(#imageLiteral(resourceName: "PlayButton"), for: .normal)
                }
                else
                {
                    self.mediaPlayerViewCollection?.playPauseButton?.setImage(#imageLiteral(resourceName: "Pause"), for: .normal)
                }

                self.mediaPlayerViewCollection?.activitySpinner?.stopAnimating()
                self.mediaPlayerViewCollection?.activitySpinner?.alpha = 0
//                self.mediaPlayerViewCollection?.activitySpinner?.isHidden = true
                self.mediaPlayerViewCollection?.errorLabel?.text = ""
                self.mediaPlayerViewCollection?.errorLabel?.isHidden = true

                if self.isControlsHidden == false && !self.isSliderChanging
                {
                    self.controlsVisibilityTimer?.invalidate()

                    self.log( msg:"++++++++ Create a Controls auto-hide timer:")

                    if self.shouldAutoHideControls
                    {
                        self.controlsVisibilityTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: false, block:
                        { (timer: Timer) in
                            self.log( msg:"++++++++ Fired timer: \(timer)")
                            self.log( msg:"And it is valid: \(timer.isValid)")

                            if timer.isValid
                            {
                                self.controlsVisibilityTimer = nil
                                self.hideControls()
                            }
                        })
                    }

                    self.log( msg:"++++++++ Timer: \(String(describing: self.controlsVisibilityTimer))")
                }

            case .paused:
                self.log( msg:"paused")

                if self.isSliderChanging == false
                {
                    self.mediaPlayerViewCollection?.playPauseButton?.setImage(#imageLiteral(resourceName: "PlayButton"), for: .normal)
                }

                self.mediaPlayerViewCollection?.activitySpinner?.stopAnimating()
                self.mediaPlayerViewCollection?.activitySpinner?.alpha = 0
//                self.mediaPlayerViewCollection?.activitySpinner?.isHidden = true

                self.mediaPlayerViewCollection?.errorLabel?.text = ""
                self.mediaPlayerViewCollection?.errorLabel?.isHidden = true

                self.showControls()

            case .failed:
                self.log( msg:"failed")
                if self.isSliderChanging == false
                {
                    self.mediaPlayerViewCollection?.playPauseButton?.setImage(#imageLiteral(resourceName: "PlayButton"), for: .normal)
                }
                
                self.mediaPlayerViewCollection?.activitySpinner?.stopAnimating()
                self.mediaPlayerViewCollection?.activitySpinner?.alpha = 0
//                self.mediaPlayerViewCollection?.activitySpinner?.isHidden = true
                self.mediaPlayerViewCollection?.errorLabel?.text = "There was a playback error."
                self.mediaPlayerViewCollection?.errorLabel?.isHidden = false

                self.showControls()

            case .buffering:
//                self.log( msg:"buffering")
                self.mediaPlayerViewCollection?.activitySpinner?.startAnimating()
                self.mediaPlayerViewCollection?.activitySpinner?.isHidden = false
                self.mediaPlayerViewCollection?.activitySpinner?.alpha = 1

                if self.isSliderChanging == false
                {
                    self.mediaPlayerViewCollection?.playPauseButton?.setImage(#imageLiteral(resourceName: "Pause"), for: .normal)
                }

                self.mediaPlayerViewCollection?.errorLabel?.text = ""
                self.mediaPlayerViewCollection?.errorLabel?.isHidden = true

            case .playedToEnd:
                self.mediaPlayerViewCollection?.activitySpinner?.stopAnimating()
                self.mediaPlayerViewCollection?.activitySpinner?.alpha = 0
//                self.mediaPlayerViewCollection?.activitySpinner?.isHidden = true

                if self.isSliderChanging == false
                {
                    self.mediaPlayerViewCollection?.playPauseButton?.setImage(#imageLiteral(resourceName: "PlayButton"), for: .normal)
                }
                
                self.mediaPlayerViewCollection?.errorLabel?.text = ""
                self.mediaPlayerViewCollection?.errorLabel?.isHidden = true

                self.showControls()

            case .idle:
                self.log( msg:"Idle")

                if self.isSliderChanging == false
                {
                    self.mediaPlayerViewCollection?.playPauseButton?.setImage(#imageLiteral(resourceName: "PlayButton"), for: .normal)
                }
                
                self.mediaPlayerViewCollection?.errorLabel?.text = ""
                self.mediaPlayerViewCollection?.errorLabel?.isHidden = true

                self.showControls()

            case .unknown:
                self.log( msg:"Unknown")
                self.mediaPlayerViewCollection?.errorLabel?.isHidden = false
        }
    }
}
