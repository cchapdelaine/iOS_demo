//
//  GameViewController.swift
//  demo
//
//  Created by Caitlin Chapdelaine on 2/8/19.
//  Copyright © 2019 Caitlin Chapdelaine. All rights reserved.
//

import UIKit
import QuartzCore
import SceneKit

class GameViewController: UIViewController {
    
    // create a sphere
    let sphere = SCNSphere(radius: 1.0)
    var sphereNode = SCNNode()
    
    let force = SCNVector3(x: 0, y: 10 , z: 0)
    let position = SCNVector3(x: 0.05, y: 0.05, z: 0.05)
    
    // .dynamic means that the physics body is affected to the laws of Physics
    let physicsBodySphere = SCNPhysicsBody(type: .dynamic, shape: nil)

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // create a sphere node
        sphereNode = SCNNode(geometry: sphere)
        
        // create a new scene
        let scene = SCNScene()
        
        // create and add a camera to the scene
        let cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        scene.rootNode.addChildNode(cameraNode)
        
        // place the camera
        cameraNode.position = SCNVector3(x: 0, y: 0, z: 30)
        
        // create and add a light to the scene
        let lightNode = SCNNode()
        lightNode.light = SCNLight()
        lightNode.light!.type = .omni
        lightNode.position = SCNVector3(x: 0, y: 10, z: 10)
        scene.rootNode.addChildNode(lightNode)
        
        // create and add an ambient light to the scene
        let ambientLightNode = SCNNode()
        ambientLightNode.light = SCNLight()
        ambientLightNode.light!.type = .ambient
        ambientLightNode.light!.color = UIColor.darkGray
        scene.rootNode.addChildNode(ambientLightNode)
        
        // Set sphere's properties
        sphere.firstMaterial?.diffuse.contents = UIColor.red
        sphereNode.position = SCNVector3(x: 0.0, y: 3.0, z: 0.0)

        // Add properties to the physics body that governs the object
        physicsBodySphere.restitution = 1.0 // How much the object bounces (0.0 to 1.0)
        physicsBodySphere.friction = 0.0
        
        // Set the sphere's physics body
        sphereNode.physicsBody = physicsBodySphere
        scene.rootNode.addChildNode(sphereNode)
        
        let ground = SCNBox(width: 10, height: 1, length: 10, chamferRadius: 1)
        ground.firstMaterial?.diffuse.contents = UIColor.yellow
        let groundNode = SCNNode(geometry: ground)
        groundNode.position = SCNVector3(x: 0.0, y: -3.0, z: 0.0)
        
        // Setting up a physics body for the ground. ".static" means that this object won't be
        // affected by the laws of physics.
        let physicsBody = SCNPhysicsBody(type: .static, shape: nil)
        physicsBody.restitution = 1.0
        physicsBody.friction = 0.0
        
        groundNode.physicsBody = physicsBody
        scene.rootNode.addChildNode(groundNode)
        
        // retrieve the SCNView
        let scnView = self.view as! SCNView
        
        // set the scene to the view
        scnView.scene = scene
        
        // allows the user to manipulate the camera
        scnView.allowsCameraControl = true
        
        // show statistics such as fps and timing information
        scnView.showsStatistics = true
        
        // configure the view
        scnView.backgroundColor = UIColor.blue
        
        // add a tap gesture recognizer
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        scnView.addGestureRecognizer(tapGesture)
    }
    
    @objc
    func handleTap(_ gestureRecognize: UIGestureRecognizer) {
        // retrieve the SCNView
        let scnView = self.view as! SCNView
        
        // check what nodes are tapped
        let p = gestureRecognize.location(in: scnView)
        let hitResults = scnView.hitTest(p, options: [:])
        
        // check that we clicked on at least one object
        if hitResults.count > 0 {
            // retrieved the first clicked object
            let result = hitResults[0]
            
            // Add force to sphere if clicked
            if result.node == sphereNode {
                physicsBodySphere.applyForce(force, at: position, asImpulse: true)
            }
            // get its material
            let material = result.node.geometry!.firstMaterial!
            
            // highlight it
            SCNTransaction.begin()
            SCNTransaction.animationDuration = 0.5
            
            // on completion - unhighlight
            SCNTransaction.completionBlock = {
                SCNTransaction.begin()
                SCNTransaction.animationDuration = 0.5
                
                material.emission.contents = UIColor.black
                
                SCNTransaction.commit()
            }
            
            material.emission.contents = UIColor.red
            
            SCNTransaction.commit()
        }
    }
    
    override var shouldAutorotate: Bool {
        return true
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .allButUpsideDown
        } else {
            return .all
        }
    }

}
