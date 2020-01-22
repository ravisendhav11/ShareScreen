//
//  SampleHandler.swift
//  ScreenShareReplayKitExtension
//
//  Created by Ravi's MacBook Pro on 21/01/20.
//  Copyright © 2020 Ravi's MacBook. All rights reserved.
//

import ReplayKit
import Starscream

class SampleHandler: RPBroadcastSampleHandler {

    let webStreamObj : SocketStream = SocketStream()
    var skipFrames: Int = 0
    var frames: NSMutableArray = []
    let screenWidthOfDevice = UIScreen.main.bounds.size.width
    let screenHeightOfDevice = UIScreen.main.bounds.size.height

    override func broadcastStarted(withSetupInfo setupInfo: [String : NSObject]?) {
        // User has requested to start the broadcast. Setup info from the UI extension can be supplied but optional.
        
        webStreamObj.intiliazeSocket()
    }
    
    override func broadcastPaused() {
        // User has requested to pause the broadcast. Samples will stop being delivered.
    }
    
    override func broadcastResumed() {
        // User has requested to resume the broadcast. Samples delivery will resume.
    }
    
    override func broadcastFinished() {
        // User has requested to finish the broadcast.
    }
    
    override func processSampleBuffer(_ sampleBuffer: CMSampleBuffer, with sampleBufferType: RPSampleBufferType) {
        switch sampleBufferType {
        case RPSampleBufferType.video:

            if (self.skipFrames > 0) {
                self.skipFrames -= 1
                return
            }
            
            self.skipFrames = 7
            let imageBuffer: CVPixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer)!
            let ciimage: CIImage = CIImage(cvPixelBuffer: imageBuffer)
            let context: CIContext = CIContext.init(options: nil)
            let cgImage: CGImage = context.createCGImage(ciimage, from: ciimage.extent)!
            let image: UIImage = UIImage.init(cgImage: cgImage)
            self.frames.add(image)
            if self.frames.count == 3 {
                let encodedImages = NSMutableArray()
                for i in 0 ..< self.frames.count {
                    var image = self.frames[i] as? UIImage
                    image = resizeimage(image: image!, withSize: CGSize(width: screenWidthOfDevice, height: screenHeightOfDevice))
                    let imageData = image!.jpegData(compressionQuality: 0.3)
                    var encodedString = imageData!.base64EncodedString(options: Data.Base64EncodingOptions.lineLength64Characters)
                    encodedString = encodedString.replacingOccurrences(of: "\n", with: "")
                    encodedString = encodedString.replacingOccurrences(of: "\r", with: "")
                    let addString = "data:image/png;base64," + encodedString
                    encodedImages.add(addString)
                }
                self.frames.removeAllObjects()
                DispatchQueue.global(qos: .background).async {
                    for str in  encodedImages {
                        self.webStreamObj.sendDataToWebServer(data: str as! String)
                    }
                    DispatchQueue.main.async {
                        // Run UI Updates
                    }
                }
            }
            break
        case RPSampleBufferType.audioApp:
            // Handle audio sample buffer for app audio
            break
        case RPSampleBufferType.audioMic:
            // Handle audio sample buffer for mic audio
            break
        @unknown default:
            // Handle other sample buffer types
            fatalError("Unknown type of sample buffer")
        }
    }
    
    func resizeimage(image: UIImage, withSize: CGSize) -> UIImage {

        let maxHeight: CGFloat = withSize.height
        let maxWidth: CGFloat = withSize.width
        let compressionQuality = 0.3
        
        let rec:CGRect = CGRect(x:0.0, y:0.0, width:maxWidth, height:maxHeight)
        UIGraphicsBeginImageContext(rec.size)
        image.draw(in: rec)
        let image: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        let imageData = image.jpegData(compressionQuality: CGFloat(compressionQuality))
        UIGraphicsEndImageContext()
        let resizedimage = UIImage(data: imageData!)
        return resizedimage!
    }

}
