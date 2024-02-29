//
//  ViewController.swift
//  ARTest2
//
//  Created by Nicola Kreis on 26.02.2024.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {
    
    @IBOutlet var sceneView: ARSCNView!
    @IBOutlet var outputView: UIView!
    @IBOutlet var outputLabel: UILabel!
    
    @IBOutlet var clockView: UIView!
    @IBOutlet var clockLabel: UILabel!
    
    @IBOutlet var blinkView: UIView!
    @IBOutlet var blinkLabel: UILabel!
    @IBOutlet var eyeClockLabel: UILabel!
    
    
    var facePoseResult = ""
    var blinkResult = "0"
    var newBlinkResult = "0"
    
    var blinkPerMinute = "0"
    var newBlinkPerMinute = ""
    var blinkCounter = 0
    var blinkCounterMinute = 0
    var blinkCheck = 0
    
    var isActive = false
    var showingAlert = false
    var time: String = "5:00"
    var minutes: Float = 5.0 {
        didSet {
            self.time = "\(Int(minutes)):00"
        }
    }
    
    var initialTime = 1
    var endDate = Date()
    
    var outputTime = ""
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard ARFaceTrackingConfiguration.isSupported else {
            fatalError("Face tracking not available on this on this device model!")
        }
        
        outputView.layer.cornerRadius = 15
        blinkView.layer.cornerRadius = 15
        clockView.layer.cornerRadius = 15
        sceneView.delegate = self
        sceneView.showsStatistics = true
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARFaceTrackingConfiguration()
        
        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
    // MARK: - ARSCNViewDelegate
    
    /*
     // Override to create and configure nodes for anchors added to the view's session.
     func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
     let node = SCNNode()
     
     return node
     }
     */
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user
        
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay
        
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required
        
    }
    
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        let faceMesh = ARSCNFaceGeometry(device: sceneView.device!)
        let node = SCNNode(geometry: faceMesh)
        node.geometry?.firstMaterial?.fillMode = .lines
        reset()
        return node
    }
    
    
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        if let faceAnchor = anchor as? ARFaceAnchor, let faceGeometry = node.geometry as? ARSCNFaceGeometry {
            faceGeometry.update(from: faceAnchor.geometry)
            facePoseAnalyzer(anchor: faceAnchor)
            updateCountdown()
            
            DispatchQueue.main.async {
                self.outputLabel.text = self.facePoseResult
                self.blinkLabel.text = self.blinkResult
                self.clockLabel.text = self.outputTime
                self.eyeClockLabel.text = self.blinkPerMinute
            }
            
        }
        
    }
    
    func facePoseAnalyzer(anchor: ARFaceAnchor) {
        let smileLeft = anchor.blendShapes[.mouthSmileLeft]
        let smileRight = anchor.blendShapes[.mouthSmileRight]
        let innerUp = anchor.blendShapes[.browInnerUp]
        let tongue = anchor.blendShapes[.tongueOut]
        let cheekPuff = anchor.blendShapes[.cheekPuff]
        let eyeBlinkLeft = anchor.blendShapes[.eyeBlinkLeft]
        let eyeBlinkRight = anchor.blendShapes[.eyeBlinkRight]
        let jawOpen = anchor.blendShapes[.jawOpen]
        
        var newFacePoseResult = ""
        
        
        
        if ((jawOpen?.decimalValue ?? 0.0) + (innerUp?.decimalValue ?? 0.0)) > 0.6 {
            newFacePoseResult = "😧"
        }
        
        if ((smileLeft?.decimalValue ?? 0.0) + (smileRight?.decimalValue ?? 0.0)) > 0.9 {
            newFacePoseResult = "😀"
        }
        
        if innerUp?.decimalValue ?? 0.0 > 0.8 {
            newFacePoseResult = "😳"
        }
        
        if tongue?.decimalValue ?? 0.0 > 0.08 {
            newFacePoseResult = "😛"
        }
        
        if cheekPuff?.decimalValue ?? 0.0 > 0.5 {
            newFacePoseResult = "🤢"
        }
        
        if eyeBlinkLeft?.decimalValue ?? 0.0 > 0.5 && eyeBlinkRight?.decimalValue ?? 0.0 > 0.5 && blinkCheck == 0{
            blinkCheck = 1
            blinkCounter += 1
            blinkCounterMinute += 1
            newBlinkResult = String(blinkCounter)
            newBlinkPerMinute = String(blinkCounterMinute)
        }
        if eyeBlinkLeft?.decimalValue ?? 0.0 < 0.5 && eyeBlinkRight?.decimalValue ?? 0.0 < 0.5{
            blinkCheck = 0
        }
        
        if self.facePoseResult != newFacePoseResult {
            self.facePoseResult = newFacePoseResult
        }
        
        if self.blinkResult != newBlinkResult {
            self.blinkResult = newBlinkResult
        }
    }
    

    @IBAction func buttonStart(){
        start(minutes: 1)
    }
    
    func start(minutes: Float) {
        blinkCounterMinute = 0
        self.initialTime = Int(minutes)
        self.endDate = Date()
        self.isActive = true
        self.endDate = Calendar.current.date(byAdding: .minute, value: Int(minutes), to: endDate)!
    }
    
    
    func reset(){
        self.minutes = Float(initialTime)
        self.isActive = false
        self.time = "\(Int(minutes)):00"
        self.outputTime = String(time)
    }

    // Show updates of the timer
    func updateCountdown(){
        guard isActive else { return }
        
        // Gets the current date and makes the time difference calculation
        let now = Date()
        let diff = endDate.timeIntervalSince1970 - now.timeIntervalSince1970
        
        // Checks that the countdown is not <= 0
        if diff <= 0 {
            self.isActive = false
            self.time = "0:00"
            self.showingAlert = true
            self.blinkPerMinute = newBlinkPerMinute
            blinkCounterMinute = 0
            return
        }
        
        // Turns the time difference calculation into sensible data and formats it
        let date = Date(timeIntervalSince1970: diff)
        let calendar = Calendar.current
        let minutes = calendar.component(.minute, from: date)
        let seconds = calendar.component(.second, from: date)
        
        // Updates the time string with the formatted time
        self.minutes = Float(minutes)
        self.time = String(format:"%d:%02d", minutes, seconds)
        self.outputTime = String(time)

    }
}


