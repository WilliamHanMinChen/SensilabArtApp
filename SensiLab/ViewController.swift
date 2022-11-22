//
//  ViewController.swift
//  SensiLab
//
//  Created by William Chen on 2022/11/10.
//

import UIKit
import RealityKit
import ARKit

class ViewController: UIViewController, ARSessionDelegate, AVAudioPlayerDelegate {
    
    //AR View reference
    @IBOutlet var arView: ARView!
    
    //Audio player reference
    var musicPlayer: AVAudioPlayer = AVAudioPlayer()
    
    //Keeps track of whether we are playing or not
    var playing: Bool = false
    
    //Keeps track of which painting we are currently playing music for
    var currentMusicPainting: String = ""
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //Setup the ARView
        //Configuration for tracking images and objects
        let configuration = ARWorldTrackingConfiguration()
        
        //Loads all the images its going to look for
        let referenceImages = ARReferenceImage.referenceImages(inGroupNamed: "AR Resources", bundle: nil)!
        
        
        //Provide it to the configuration
        configuration.detectionImages = referenceImages
        
        //Give it a maximum number it can track at the same time
        configuration.maximumNumberOfTrackedImages = 10
        
        
        // Set ARView delegate so we can define delegate methods in this controller
        arView.session.delegate = self
        
        // Forgo automatic configuration to do it manually instead
        arView.automaticallyConfigureSession = false
        
        // Disable any unneeded rendering options
        arView.renderOptions = [.disableCameraGrain, .disableHDR, .disableMotionBlur, .disableDepthOfField, .disableFaceMesh, .disablePersonOcclusion, .disableGroundingShadows, .disableAREnvironmentLighting]
        
        //Run the session
        arView.session.run(configuration)
        
        
    }
    
    // MARK: ARView delegate methods
    
    func session(_ session: ARSession, didAdd anchors: [ARAnchor]) {
        
//        //Loop through each of the added anchors
//        for anchor in anchors{
//
//            if let imageAnchor = anchor as? ARImageAnchor { //If it is an image anchor
//
//                //Get the anchor and camera position
//                let anchorPosition = imageAnchor.transform.columns.3
//                guard let cameraPosition = session.currentFrame?.camera.transform.columns.3 else { fatalError("Could not get camera values") }
//
//                //A line from camera to anchor (to measure the distance)
//                let cameraToAnchor = cameraPosition - anchorPosition
//
//                //Gets the reference image it found
//                let referenceImage = imageAnchor.referenceImage
//
//                guard let name = referenceImage.name else {
//                    fatalError("This anchor does not have a name")
//                }
//
//            }
//        }
        
    }
    
    
    
    func session(_ session: ARSession, didUpdate anchors: [ARAnchor]) {
        
        //Get the camera position
        guard let cameraPosition = session.currentFrame?.camera.transform.columns.3 else { fatalError("Could not get camera values") }
        
        //Sort the anchors by distance , closest first
        let anchors = anchors.sorted(by: { length(cameraPosition - $0.transform.columns.3) < length(cameraPosition - $1.transform.columns.3)})
        
        //Initialise the anchor distance variable
        var anchorDistance = 0.0
        
        //Loop through the anchors (Currently tracked images)
        for anchor in anchors {
            let anchorPosition = anchor.transform.columns.3
            //Create a line between the camera and the anchor
            let cameraToAnchor = cameraPosition - anchorPosition
            //Get the scalar distance
            anchorDistance = Double(length(cameraToAnchor))
            
            //Print it for debugging
            //print("\(anchor.name) \(anchorDistance) m")
        }
        
        
        
        //If it is an image anchor
        if let anchor = anchors.first as? ARImageAnchor{
        
            print("Found \(anchor.name)")
            do {
                //Play if we are currently not playing or we have moved to a new anchor
                if !playing || currentMusicPainting != anchor.name{
                    
                    //If we are playing somethint stop it
                    if musicPlayer.isPlaying{
                        musicPlayer.stop()
                    }
                    
                    playing = true
                    currentMusicPainting = anchor.name ?? ""
                    //Get the Music URL
                    guard let musicURL = Bundle.main.url(forResource: anchor.name, withExtension: "wav") else {
                        fatalError("Failed to get URL for painting \(anchor.name)")
                    }
                    musicPlayer = try AVAudioPlayer(contentsOf: musicURL)
                    //Set our delegate
                    musicPlayer.delegate = self
                    musicPlayer.play()
                    print("playing music now")
                }
                
            } catch {
                fatalError("error while loading file \(error.localizedDescription)")
            }
            
        }
        
    }
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        playing = false
    }
    
    
    
    
}
