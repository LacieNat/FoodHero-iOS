//
//  ShareFoodView.swift
//  FoodHero
//
//  Created by Lacie on 6/16/16.
//  Copyright © 2016 Lacie. All rights reserved.
//

import Foundation
import AVFoundation

class ShareFoodCameraView: UIViewController {
    let captureSession = AVCaptureSession()
    var captureDevice : AVCaptureDevice?
    var frontCaptureDevice: AVCaptureDevice?
    var backCaptureDevice: AVCaptureDevice?
    var previewLayer : AVCaptureVideoPreviewLayer?
    var imageOutput : AVCaptureStillImageOutput?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        captureSession.sessionPreset = AVCaptureSessionPresetPhoto
        let devices = AVCaptureDevice.devices()
    
        
        for device in devices {
            // Make sure this particular device supports video
            if (device.hasMediaType(AVMediaTypeVideo)) {
                // Finally check the position and confirm we've got the back camera
                if(device.position == AVCaptureDevicePosition.Back) {
                    captureDevice = device as? AVCaptureDevice
                    backCaptureDevice = captureDevice
                }
                
                if(device.position == AVCaptureDevicePosition.Front){
                    frontCaptureDevice = device as? AVCaptureDevice
                }
            }
        }
        
        if captureDevice != nil {
            beginSession()
        }
        
    }
    
    func beginSession() {
        
        do {
            try configureDevice()
            try captureSession.addInput(AVCaptureDeviceInput(device: captureDevice))
        } catch {
            print ("begin session error")
        }
        
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        self.view.layer.addSublayer(previewLayer!)
        previewLayer?.frame = self.view.layer.frame
        imageOutput?.outputSettings = [AVVideoCodecKey:AVVideoCodecJPEG]
        
        if captureSession.canAddOutput(imageOutput) {
            captureSession.addOutput(imageOutput)
        }
        
        captureSession.startRunning()
    }
    
    func saveToCamera(sender: UITapGestureRecognizer) {
        if let videoConnection = imageOutput!.connectionWithMediaType(AVMediaTypeVideo) {
            imageOutput!.captureStillImageAsynchronouslyFromConnection(videoConnection) {
                (imageDataSampleBuffer, error) -> Void in
                let imageData = AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(imageDataSampleBuffer)
                UIImageWriteToSavedPhotosAlbum(UIImage(data: imageData)!, nil, nil, nil)
            }
        }
    }
    
    func configureDevice() throws{
        if let device = captureDevice {
            try device.lockForConfiguration()
            //device.focusMode = .Locked
            device.focusMode = AVCaptureFocusMode.ContinuousAutoFocus
            device.exposureMode = .ContinuousAutoExposure
            device.unlockForConfiguration()
        }
    }
    
    func switchDevice() throws {
        captureSession.beginConfiguration()
        try captureSession.removeInput(AVCaptureDeviceInput(device:captureDevice))
       
        if captureDevice!.position == AVCaptureDevicePosition.Back {
            captureDevice = frontCaptureDevice
        } else {
            captureDevice = backCaptureDevice
        }
        
        try captureSession.addInput(AVCaptureDeviceInput(device:captureDevice))
        
        captureSession.commitConfiguration()
    }
    
//    func focusTo(value : Float) throws {
//        if let device = captureDevice {
//            try device.lockForConfiguration()
//            device.setFocusModeLockedWithLensPosition(value, completionHandler: { (time) -> Void in
//                
//            })
//            device.unlockForConfiguration()
//            
//        }
//    }
//    
//    let screenWidth = UIScreen.mainScreen().bounds.size.width
//    
//    func touchPerc(touch : UITouch) -> CGPoint {
//        // Get the dimensions of the screen in points
//        let screenSize = UIScreen.mainScreen().bounds.size
//        
//        // Create an empty CGPoint object set to 0, 0
//        var touchPer = CGPointZero
//        
//        // Set the x and y values to be the value of the tapped position, divided by the width/height of the screen
//        touchPer.x = touch.locationInView(self.view).x / screenSize.width
//        touchPer.y = touch.locationInView(self.view).y / screenSize.height
//        
//        // Return the populated CGPoint
//        return touchPer
//    }
//    
//    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
//        var anyTouch = touches.first
//        var touchPercent = touchPerc(anyTouch!)
//        do {
//            //try focusTo(Float(touchPercent.x))
//            try updateDeviceSettings(Float(touchPercent.x), isoValue: (Float(touchPercent.y)))
//        } catch {
//            
//        }
//        super.touchesBegan(touches, withEvent: event)
//    }
//    
//    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
//        var anyTouch = touches.first
//        var touchPercent = touchPerc(anyTouch!)
//        do {
//            //try focusTo(Float(touchPercent.x))
//            try updateDeviceSettings(Float(touchPercent.x), isoValue: (Float(touchPercent.y)))
//        } catch {
//            
//        }
//        super.touchesBegan(touches, withEvent: event)
//
//    }
//    
//    func updateDeviceSettings(focusValue : Float, isoValue : Float) throws {
//        if let device = captureDevice {
//            try device.lockForConfiguration()
//                device.setFocusModeLockedWithLensPosition(focusValue, completionHandler: { (time) -> Void in
//                    //
//                })
//                
//                // Adjust the iso to clamp between minIso and maxIso based on the active format
//                let minISO = device.activeFormat.minISO
//                let maxISO = device.activeFormat.maxISO
//                let clampedISO = isoValue * (maxISO - minISO) + minISO
//                
//                device.setExposureModeCustomWithDuration(AVCaptureExposureDurationCurrent, ISO: clampedISO, completionHandler: { (time) -> Void in
//                    //
//                })
//                
//                device.unlockForConfiguration()
//            
//        }
//    }
    
}