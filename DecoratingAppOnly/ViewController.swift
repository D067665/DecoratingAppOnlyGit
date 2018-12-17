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
    
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var addModel: UIButton!
    private var modelNode: SCNReferenceNode!
    var focalNode: FocalNode?
    var anchor: ARAnchor?
    private var screenCenter: CGPoint!
    private var selectedNode: SCNNode?
    private var originalRotation: SCNVector3?
    let modelArray = ["CowboyBoots","Vase"]
    var modelName = "CowboyBoots"
    var worldMapURL: URL = {
        do {
            return try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
                .appendingPathComponent("worldMapURL")
        } catch {
            fatalError("Error getting world map URL from document directory.")
        }
    }()
    
    
    /*let session = ARSession()
    let sessionConfiguration: ARWorldTrackingConfiguration = {
        let config = ARWorldTrackingConfiguration()
        config.planeDetection = .horizontal
        return config
    }()*/
    override func viewDidLoad() {
        super.viewDidLoad()
        screenCenter = view.center
        
        // Report updates to the view controller
        sceneView.delegate = self as ARSCNViewDelegate
        
        // Use the session that we created
        //sceneView.session = session
        
        // Use the default lighting so that our objects are illuminated
        sceneView.automaticallyUpdatesLighting = true
        sceneView.autoenablesDefaultLighting = true
        
        // Update at 60 frames per second (recommended by Apple)
        sceneView.preferredFramesPerSecond = 60
        sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints]
        
        
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapped))
        
        sceneView.addGestureRecognizer(tapGesture)
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
        resetTrackingConfiguration()
        
        // Make sure that ARKit is supported
        /*if ARWorldTrackingConfiguration.isSupported {
            session.run(sessionConfiguration, options: [.removeExistingAnchors, .resetTracking])
        } else {
            print("Sorry, your device doesn't support ARKit")
        }*/
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        // Pause ARKit while the view is gone
        sceneView.session.pause()
        
        super.viewWillDisappear(animated)
    }
    
    
    
    @objc func tapped(sender: UITapGestureRecognizer){
        let sceneView = sender.view as! ARSCNView
        let tapLocation = sender.location(in: sceneView)

        let hitTest = sceneView.hitTest(tapLocation, types: .existingPlaneUsingExtent)
        if !hitTest.isEmpty{
        print("Touched on the plane")
        let hitTestResult = hitTest.first!
            anchor = ARAnchor(name: "\(modelName)", transform: hitTestResult.worldTransform)
            print ("Anchor Name: , \(anchor!.name)" )
    
            self.sceneView.session.add(anchor: anchor!)
           
        }else{
            print("Not a plane")}
        }
       

    
    @objc func removeNode(gesture: UILongPressGestureRecognizer){
       
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
    
    
    /*func addModel(hitTestResult:ARHitTestResult){
        
        guard let scene = SCNScene(named: "\(modelName).scn") else{return}
        
        let node = (scene.rootNode.childNode(withName: modelName, recursively: false))!
        if(modelName == "CowboyBoots"){
            node.scale = SCNVector3(0.1, 0.1, 0.1)
        }
        
        let transform = hitTestResult.worldTransform
        let thirdColumn = transform.columns.3
        node.position = SCNVector3(thirdColumn.x, thirdColumn.y, thirdColumn.z)
        self.sceneView.scene.rootNode.addChildNode(node)
    }*/
    
    func addNode() -> SCNReferenceNode{
        let sceneURL = Bundle.main.url(forResource: "\(modelName)", withExtension: ".scn")!
        let node = SCNReferenceNode(url: sceneURL)!
        if(modelName == "CowboyBoots"){
            node.scale = SCNVector3(0.1, 0.1, 0.1)
        }
        node.load()
        return node
        
    }
    
    func addBootsNode() -> SCNReferenceNode{
        let sceneURL = Bundle.main.url(forResource: "CowboyBoots", withExtension: ".scn")!
        let node = SCNReferenceNode(url: sceneURL)!
        
        node.scale = SCNVector3(0.1, 0.1, 0.1)
        
        node.load()
        return node
        
    }
    func addVaseNode() -> SCNReferenceNode{
        let sceneURL = Bundle.main.url(forResource: "Vase", withExtension: ".scn")!
        let node = SCNReferenceNode(url: sceneURL)!
        
        node.load()
        return node
        
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
    
    func archive(worldMap: ARWorldMap) throws {
        let data = try NSKeyedArchiver.archivedData(withRootObject: worldMap, requiringSecureCoding: true)
        try data.write(to: self.worldMapURL, options: [.atomic])
    }
    func retrieveWorldMapData(from url: URL) -> Data? {
        do {
            return try Data(contentsOf: self.worldMapURL)
        } catch {
            self.label.text = "Error retrieving world map data."
            return nil
        }
    }
    
    func unarchive(worldMapData data: Data) -> ARWorldMap? {
        guard let unarchievedObject = try? NSKeyedUnarchiver.unarchivedObject(ofClass: ARWorldMap.self, from: data),
            let worldMap = unarchievedObject else { return nil }
        return worldMap
    }
    
    func resetTrackingConfiguration(with worldMap: ARWorldMap? = nil) {
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = [.horizontal]
        
        let options: ARSession.RunOptions = [.resetTracking, .removeExistingAnchors]
        if let worldMap = worldMap {
            configuration.initialWorldMap = worldMap
            self.label.text = "Found saved world map."
        } else {
            self.label.text = "Move camera around to map your surrounding space."
        }
        
        sceneView.debugOptions = [.showFeaturePoints]
        sceneView.session.run(configuration, options: options)
    }
    
    
    
    @IBAction func loadBarButtonPressed(_ sender: UIBarButtonItem) {
        guard let worldMapData = retrieveWorldMapData(from: worldMapURL),
            let worldMap = unarchive(worldMapData: worldMapData) else { return }
        resetTrackingConfiguration(with: worldMap)
    }
    
    
    @IBAction func saveBarButtonPressed(_ sender: UIBarButtonItem) {
        
        sceneView.session.getCurrentWorldMap { (worldMap, error) in
            guard let worldMap = worldMap else {
                return self.label.text =  "Error getting current world map."
            }
            
            do {
                try self.archive(worldMap: worldMap)
                DispatchQueue.main.async {
                    self.label.text = "World map is saved."
                }
            } catch {
                fatalError("Error saving world map: \(error.localizedDescription)")
            }
        }
    }
    
    
    
    
}
extension UIColor {
    open class var transparentLightBlue: UIColor {
        return UIColor(red: 90/255, green: 200/255, blue: 250/255, alpha: 0.50)
    }
}

extension float4x4 {
    var translation: float3 {
        let translation = self.columns.3
        return float3(translation.x, translation.y, translation.z)
    }
}

extension ViewController: ARSCNViewDelegate {
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        guard !(anchor is ARPlaneAnchor) else { return }
        if (anchor.name == "Vase"){
            modelNode = addVaseNode()
        }
        if(anchor.name == "CowboyBoots"){
            modelNode = addBootsNode()
        }
        //modelNode = addNode()
        //modelNode.position = SCNVector3((anchor.transform.translation))
        //sceneView.scene.rootNode.addChildNode(node)
        node.addChildNode(modelNode)
        /*DispatchQueue.main.async {
            node.addChildNode(modelNode)
        }*/
        
        /*// 1 unwrap anchor
        guard let planeAnchor = anchor as? ARPlaneAnchor else { return }
        
        // 2 visualize anchor
        let width = CGFloat(planeAnchor.extent.x)
        let height = CGFloat(planeAnchor.extent.z)
        let plane = SCNPlane(width: width, height: height)
        
        // 3
        plane.materials.first?.diffuse.contents = UIColor.transparentLightBlue
        
        // 4
        let planeNode = SCNNode(geometry: plane)
        
        // 5
        let x = CGFloat(planeAnchor.center.x)
        let y = CGFloat(planeAnchor.center.y)
        let z = CGFloat(planeAnchor.center.z)
        planeNode.position = SCNVector3(x,y,z)
        planeNode.eulerAngles.x = -.pi / 2
        
        // 6
        node.addChildNode(planeNode)
        
        
        // If we have already created the focal node we should not do it again
        guard focalNode == nil else { return }*/
        
        
 
 
    }
    
    
    
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        
        // 1 unwrap anchor
        guard let planeAnchor = anchor as?  ARPlaneAnchor,
            //unwrap node
            let planeNode = node.childNodes.first,
            let plane = planeNode.geometry as? SCNPlane
            else { return }
        
        // 2 update planes width & height
        let width = CGFloat(planeAnchor.extent.x)
        let height = CGFloat(planeAnchor.extent.z)
        plane.width = width
        plane.height = height
        
        // 3 update position
        let x = CGFloat(planeAnchor.center.x)
        let y = CGFloat(planeAnchor.center.y)
        let z = CGFloat(planeAnchor.center.z)
        planeNode.position = SCNVector3(x, y, z)
        
    }
}

