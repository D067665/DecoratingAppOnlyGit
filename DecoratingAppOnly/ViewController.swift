//
//  ViewController.swift
//  DecoratingAppOnly
//
//  Created by Schmidt, Denise on 13.12.18.
//  Copyright © 2018 Schmidt, Denise. All rights reserved.
//

import UIKit
import ARKit
import SceneKit

class ViewController: UIViewController {

    @IBOutlet weak var sceneView: ARSCNView!
    @IBOutlet weak var searchingLabel: UILabel!
    @IBOutlet weak var addModel: UIButton!
    private var modelNode: SCNNode!
    var focalNode: FocalNode?
    private var screenCenter: CGPoint!
    private var selectedNode: SCNNode?
    private var originalRotation: SCNVector3?
    let modelArray = ["CowboyBoots","Vase"]
    var modelName = "CowboyBoots"
    
    let session = ARSession()
    let sessionConfiguration: ARWorldTrackingConfiguration = {
        let config = ARWorldTrackingConfiguration()
        config.planeDetection = .horizontal
        return config
    }()
    override func viewDidLoad() {
        super.viewDidLoad()
        screenCenter = view.center
        
        // Report updates to the view controller
        sceneView.delegate = self as ARSCNViewDelegate
        
        // Use the session that we created
        sceneView.session = session
        
        // Use the default lighting so that our objects are illuminated
        sceneView.automaticallyUpdatesLighting = true
        sceneView.autoenablesDefaultLighting = true
        
        // Update at 60 frames per second (recommended by Apple)
        sceneView.preferredFramesPerSecond = 60
        
          // Get the scene the model is stored in
       /* let modelScene = SCNScene(named: "CowboyBoots.scn")!
        
        // Get the model from the root node of the scene
        modelNode = modelScene.rootNode
        
        // Scale down the model to fit the real world better
        modelNode.scale = SCNVector3(0.1, 0.1, 0.1)
        
        // Rotate the model 90 degrees so it sits even to the floor
        //modelNode.transform = SCNMatrix4Rotate(modelNode.transform, Float.pi / 2.0, 1.0, 0.0, 0.0)*/
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapped))
        
        sceneView.addGestureRecognizer(tapGesture)
        
        /*let doubleTapGesture = UITapGestureRecognizer(target: self, action: #selector(didDoubleTapScreen))
        doubleTapGesture.numberOfTapsRequired = 2
        doubleTapGesture.numberOfTouchesRequired = 1
        sceneView.addGestureRecognizer(doubleTapGesture)*/
        
        
        // Tracks pans on the screen
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(moveNode(_:)))
        sceneView.addGestureRecognizer(panGesture)
        
        // Tracks rotation gestures on the screen
        let rotationGesture = UIRotationGestureRecognizer(target: self, action: #selector(rotateNode(_:)))
        sceneView.addGestureRecognizer(rotationGesture)
        let longTapGesture = UILongPressGestureRecognizer(target: self, action: #selector(removeNode))
        longTapGesture.minimumPressDuration = 0.5;
        sceneView.addGestureRecognizer(longTapGesture)
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Make sure that ARKit is supported
        if ARWorldTrackingConfiguration.isSupported {
            session.run(sessionConfiguration, options: [.removeExistingAnchors, .resetTracking])
        } else {
            print("Sorry, your device doesn't support ARKit")
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        // Pause ARKit while the view is gone
        session.pause()
        
        super.viewWillDisappear(animated)
    }
    
    
    
    @objc func tapped(sender: UITapGestureRecognizer){
        let sceneView = sender.view as! ARSCNView
        let tapLocation = sender.location(in: sceneView)
        
        let hitTest = sceneView.hitTest(tapLocation, types: .existingPlaneUsingExtent)
        if !hitTest.isEmpty{
            print("Touched on the plane")
            addModel(hitTestResult: hitTest.first!)
        }
        else{
            print("Not a plane")
        }
    }
    
    @objc func removeNode(gesture: UILongPressGestureRecognizer){
       /* if( sender.state != .began){
            return
        }
        let sceneView = sender.view as! ARSCNView
        let location = sender.location(in: sceneView)
        
        var hitTestOptions = [SCNHitTestOption: Any]()
        hitTestOptions[SCNHitTestOption.boundingBoxOnly] = true
        let hitResults: [SCNHitTestResult]  =
            sceneView.hitTest(location, options: hitTestOptions)
        if let hit = hitResults.first {
            if let node = getParent(hit.node) {
                node.removeFromParentNode()
                return
            }
        }*/
        //1. Get The Current Touch Point
        let currentTouchPoint = gesture.location(in: sceneView)
        
        //2. If The Gesture State Has Begun Perform A Hit Test To Get The SCNNode At The Touch Location
        if gesture.state == .began{
            
            //2a. Perform An SCNHitTest To Detect If An SCNNode Has Been Touched
            guard let nodeHitTest = sceneView.hitTest(currentTouchPoint, options: nil).first else { return }
            
            //2b. Get The SCNNode Result
            let nodeHit = nodeHitTest.node
            
            //2c. Set As The Current Node
            selectedNode = nodeHit
            selectedNode?.removeFromParentNode()
            
        }
        
        
        if gesture.state == .ended{
            selectedNode = nil
        }
        
        
    }
    /*@objc func didDoubleTapScreen(sender: UITapGestureRecognizer){
        let sceneView = sender.view as! ARSCNView
        let location = sender.location(in: sceneView)
        
        var hitTestOptions = [SCNHitTestOption: Any]()
        hitTestOptions[SCNHitTestOption.boundingBoxOnly] = true
        let hitResults: [SCNHitTestResult]  =
            sceneView.hitTest(location, options: hitTestOptions)
        if let hit = hitResults.first {
            if let node = getParent(hit.node) {
                node.removeFromParentNode()
                return
            }
        }
    }*/
    
    func addModel(hitTestResult:ARHitTestResult){
        
        guard let scene = SCNScene(named: "\(modelName).scn") else{return}
        
        let node = (scene.rootNode.childNode(withName: modelName, recursively: false))!
        if(modelName == "CowboyBoots"){
            node.scale = SCNVector3(0.1, 0.1, 0.1)
        }
        
        let transform = hitTestResult.worldTransform
        let thirdColumn = transform.columns.3
        node.position = SCNVector3(thirdColumn.x, thirdColumn.y, thirdColumn.z)
        self.sceneView.scene.rootNode.addChildNode(node)
    }
    @IBAction func addModelButtonTapped(_ sender: UIButton) {
        let alertController = UIAlertController(title: "Select Model", message: "", preferredStyle: .actionSheet)
        alertController.popoverPresentationController?.sourceView = sender
        for modelName in modelArray{
            let alertAction = UIAlertAction(title: modelName, style: .default){[weak self] (_) in self?.modelName = modelName
            }
            alertController.addAction(alertAction)
        }
        present(alertController, animated: true, completion: nil)
    }
    
   /* @objc private func viewTapped(_ gesture: UITapGestureRecognizer) {
        // Make sure we've found the floor
        guard focalNode != nil else { return }
        
        // See if we tapped on a plane where a model can be placed
        let results = sceneView.hitTest(screenCenter, types: .existingPlane)
        guard let transform = results.first?.worldTransform else { return }
        
        // Find the position to place the model
        let position = float3(transform.columns.3.x, transform.columns.3.y, transform.columns.3.z)
        
        /*// Create a copy of the model set its position/rotation
        // Get the scene the model is stored in
        let newScene = SCNScene(named: "CowboyBoots.scn")!
        
        // Get the model from the root node of the scene
        let newNode = newScene.rootNode
        
        // Scale down the model to fit the real world better
        newNode.scale = SCNVector3(0.1, 0.1, 0.1)*/
        
        // Rotate the model 90 degrees so it sits even to the floor
        
        let newNode = modelNode.flattenedClone()
        newNode.simdPosition = position
        
        // Add the model to the scene
        sceneView.scene.rootNode.addChildNode(newNode)
        
        //node.append(newNode)
    }*/
    
    private func node(at position: CGPoint) -> SCNNode? {
        return sceneView.hitTest(position, options: nil)
            .first(where: { $0.node !== focalNode && $0.node !== modelNode })?
            .node
    }
   
    @objc private func rotateNode(_ gesture: UIRotationGestureRecognizer){
        let currentTouchPoint = gesture.location(in: sceneView)
        let hitTest = sceneView.hitTest(currentTouchPoint)
        if !hitTest.isEmpty{
            let node = hitTest.first?.node
            if gesture.state == .began || gesture.state == .changed {
                node?.eulerAngles = SCNVector3(CGFloat((node?.eulerAngles.x)!),gesture.rotation,CGFloat((node?.eulerAngles.z)!))
            }
        }
        
      
        

    }
    
   /* @objc private func viewRotated(_ gesture: UIRotationGestureRecognizer) {
        let location = gesture.location(in: sceneView)
        
        guard let node = node(at: location) else { return }
        
        switch gesture.state {
        case .began:
            originalRotation = node.eulerAngles
        case .changed:
            guard var originalRotation = originalRotation else { return }
            originalRotation.y -= Float(gesture.rotation)
            node.eulerAngles = originalRotation
        default:
            originalRotation = nil
        }
    }*/
    
    @objc func moveNode(_ gesture: UIPanGestureRecognizer) {
        
        //1. Get The Current Touch Point
        let currentTouchPoint = gesture.location(in: sceneView)
        
        //2. If The Gesture State Has Begun Perform A Hit Test To Get The SCNNode At The Touch Location
        if gesture.state == .began{
            
            //2a. Perform An SCNHitTest To Detect If An SCNNode Has Been Touched
            guard let nodeHitTest = sceneView.hitTest(currentTouchPoint, options: nil).first else { return }
            
            //2b. Get The SCNNode Result
            let nodeHit = nodeHitTest.node
            
            //2c. Set As The Current Node
            selectedNode = nodeHit
            
        }
        
        //3. If The Gesture State Has Changed Then Perform An ARSCNHitTest To Detect Any Existing Planes
        if gesture.state == .changed{
            
            //3b. Get The Next Feature Point Etc
            guard let hitTest = sceneView.hitTest(currentTouchPoint, types: .existingPlane).first else { return }
            
            //3c. Convert To World Coordinates
            let worldTransform = hitTest.worldTransform
            
            //3d. Set The New Position
            let newPosition = SCNVector3(worldTransform.columns.3.x, worldTransform.columns.3.y, worldTransform.columns.3.z)
            
            //3e. Apply To The Node
            selectedNode?.simdPosition = float3(newPosition.x, newPosition.y, newPosition.z)
            
        }
        
        //4. If The Gesture State Has Ended Remove The Reference To The Current Node
        if gesture.state == .ended{
            selectedNode = nil
        }
    }
    /*override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let location = touches.first!.location(in: sceneView)
        var hitTestOptions = [SCNHitTestOption: Any]()
        hitTestOptions[SCNHitTestOption.boundingBoxOnly] = true
        let hitResults: [SCNHitTestResult]  =
            sceneView.hitTest(location, options: hitTestOptions)
        if let hit = hitResults.first {
            if let node = getParent(hit.node) {
                node.removeFromParentNode()
                return
            }
        }
        
    }*/
    func getParent(_ nodeFound: SCNNode?) -> SCNNode? {
        if let node = nodeFound {
            if node.name == modelName {
                return node
            } else if let parent = node.parent {
                return getParent(parent)
            }
        }
        return nil
    }
    
    
    
}
extension ViewController: ARSCNViewDelegate {
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        
        // If we have already created the focal node we should not do it again
        guard focalNode == nil else { return }
        
        // Create a new focal node
        //let node = FocalNode()
       //node.addChildNode(modelNode)
        
        // Add it to the root of our current scene
        //sceneView.scene.rootNode.addChildNode(node)
        
        // Store the focal node
        //self.focalNode = node
        
        
        
        /*
        // Hide the label (making sure we're on the main thread)
        DispatchQueue.main.async {
            UIView.animate(withDuration: 0.5, animations: {
                self.searchingLabel.alpha = 0.0
            }, completion: { _ in
                self.searchingLabel.isHidden = true
            })
        }*/
 
 
    }
    
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        // If we haven't established a focal node yet do not update
        guard let focalNode = focalNode else { return }
        
        // Determine if we hit a plane in the scene
        let hit = sceneView.hitTest(screenCenter, types: .existingPlane)
        
        // Find the position of the first plane we hit
        guard let positionColumn = hit.first?.worldTransform.columns.3 else { return }
        
        // Update the position of the node
        focalNode.position = SCNVector3(x: positionColumn.x, y: positionColumn.y, z: positionColumn.z)
    }
}

