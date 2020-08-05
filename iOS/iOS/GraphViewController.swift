//
//  GraphViewController.swift
//  AR_APP
//
//  Created by bei on 2020/07/30.
//  Copyright © 2020 bei. All rights reserved.
//

import UIKit
import ARKit

class GraphViewController: UIViewController {

        @IBOutlet weak var mainSceneView: ARSCNView!
        @IBOutlet var label: UILabel!
        var CenterLocation: CGPoint!
        let configuration = ARWorldTrackingConfiguration()
        var selectedItem: String?
        var selectedgraph: String?

        override func viewDidLoad() {
            super.viewDidLoad()

            initialize()
            registerGestureRecognizers()
            CenterLocation = CGPoint(x: self.view.frame.midX, y: self.view.frame.midY)
        }

        override func didReceiveMemoryWarning() {
            super.didReceiveMemoryWarning()
        }

        /// ARSCNiew初期化設定
        func initialize (){
            self.configuration.planeDetection = .horizontal
            self.mainSceneView.session.run(configuration)
            self.mainSceneView.autoenablesDefaultLighting = true
        }

        ///　メインのビューのタップを検知するように設定する
        func registerGestureRecognizers() {
            let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(tapped))
            self.mainSceneView.addGestureRecognizer(tapGestureRecognizer)
        }

        @objc func tapped(sender: UITapGestureRecognizer) {
            // タップされた位置を取得する
            let sceneView = sender.view as! ARSCNView
            let tapLocation = sender.location(in: sceneView)
            let pointLocation = CGPoint(x: tapLocation.x - CenterLocation.x, y: -(tapLocation.y - CenterLocation.y))
            Swift.print(pointLocation)
            label.text = pointLocation.debugDescription
            // タップされた位置のARアンカーを探す
            let hitTest = sceneView.hitTest(tapLocation, types: .featurePoint)
            if !hitTest.isEmpty {
                // タップした箇所が取得できていればitemを追加
                self.addItem(hitTestResult: hitTest.first!)
            }
        }

        /// アイテム配置メソッド
        func addItem(hitTestResult: ARHitTestResult) {
            // 現実世界の座標を取得
            let transform = hitTestResult.worldTransform
            let thirdColumn = transform.columns.3
            if let selectedItem = self.selectedItem, let selectedgraph = self.selectedgraph{
                // アセットより、シーンを作成
                guard let scene = SCNScene(named: "art.scnassets/\(selectedItem).scn")else{return}
                guard let scene2 = SCNScene(named: "art.scnassets/\(String(describing: selectedgraph)).scn")else{return}
                // ノード作成
                let node = SCNNode()
                let Graphnode = SCNNode()
                
                for childNode in scene.rootNode.childNodes {
                    node.addChildNode(childNode)
                }
                for childNode2 in scene2.rootNode.childNodes {
                    Graphnode.addChildNode(childNode2)
                }
                // アイテムの配置
                if selectedItem == "grid3"{
                    let position = SCNVector3(0, 0, -0.6)
                    node.scale = SCNVector3(0.3, 0.3, 0.3)
                    if let camera = mainSceneView.pointOfView {
                        node.position = camera.convertPosition(position, to: nil)
                    }
                    Graphnode.position = SCNVector3(thirdColumn.x, thirdColumn.y, -0.3)
                    Graphnode.scale = SCNVector3(0.002, 0.002, 0.002)
                } else if selectedItem == "gridandgraph2"{
                    node.position = SCNVector3(thirdColumn.x, thirdColumn.y, -0.3)
                    node.scale = SCNVector3(0.05, 0.05, 0.05)
                    Graphnode.position = SCNVector3(thirdColumn.x, thirdColumn.y, -0.3)
                    Graphnode.scale = SCNVector3(0.1, 0.1, 0.1)
                }
                let billboardConstrait = SCNBillboardConstraint()
                billboardConstrait.freeAxes = SCNBillboardAxis.Y
                node.constraints = [billboardConstrait]
                Graphnode.constraints = [billboardConstrait]
                self.mainSceneView.scene.rootNode.addChildNode(node)
                self.mainSceneView.scene.rootNode.addChildNode(Graphnode)
            }
                
            else if let selectedItem = self.selectedItem{
                    guard let subscene = SCNScene(named: "art.scnassets/\(selectedItem).scn")else{return}
                    let subnode = SCNNode()
                    for childNode in subscene.rootNode.childNodes {
                        subnode.addChildNode(childNode)
                    }
                    subnode.position = SCNVector3(thirdColumn.x, thirdColumn.y, -0.3)
                    subnode.scale = SCNVector3(0.1, 0.1, 0.1)
                    let billboardConstrait = SCNBillboardConstraint()
                    billboardConstrait.freeAxes = SCNBillboardAxis.Y
                    subnode.constraints = [billboardConstrait]
                    self.mainSceneView.scene.rootNode.addChildNode(subnode)
                }
            }
        /*@IBAction func pButtonTapped(_ sender: Any) {
            selectedItem = "gridandgraph2"
            selectedgraph = "sphere"
        }*/
        @IBAction func cupButtonTapped(_ sender: Any) {
            selectedItem = "sphere"
            selectedgraph = nil
        }
        @IBAction func wineButtonTapped(_ sender: Any) {
            selectedItem = "grid3"
            selectedgraph = "newgraph"
        }
    @IBAction func returnButton(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
}
