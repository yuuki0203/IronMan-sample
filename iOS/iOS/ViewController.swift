//
//  ViewController.swift
//  AR_APP
//
//  Created by bei on 2020/06/24.
//  Copyright © 2020 bei. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate, UIGestureRecognizerDelegate{
    
    @IBOutlet var sceneView: ARSCNView!
    var selectNode: SCNNode!
    /// 検出用configを作成
    let configuration = ARWorldTrackingConfiguration()
    var selectedItem: String?
    override func viewDidLoad() {
        super.viewDidLoad()
        initialize()
        registerGestureRecognizers()
        //scale gesture
        let pinch = UIPinchGestureRecognizer(
             target: self,
             action: #selector(type(of: self).scenePinchGesture(_:))
        )
        pinch.delegate = self
        sceneView.addGestureRecognizer(pinch)
    }
    /// ARSCNview初期化設定
    func initialize (){
        self.sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints]
        self.configuration.planeDetection = .horizontal
        self.sceneView.session.run(configuration)
        self.sceneView.autoenablesDefaultLighting = true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    ///　メインのビューのタップを検知するように設定する
    func registerGestureRecognizers() {
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(tapped))
        self.sceneView.addGestureRecognizer(tapGestureRecognizer)
    }
    
    @objc func tapped(sender: UITapGestureRecognizer) {
        // タップされた位置を取得する
        let sceneView = sender.view as! ARSCNView
        let tapLocation = sender.location(in: sceneView)
        
        // タップされた位置のARアンカーを探す
        let hitTest = sceneView.hitTest(tapLocation, types: .estimatedHorizontalPlane)
        if !hitTest.isEmpty {
            // タップした箇所が取得できていればitemを追加
            self.addItem(hitTestResult: hitTest.first!)
        }
        else
        {
            print("Not hit")
        }
    }
    
    
    /// アイテム配置メソッド
    func addItem(hitTestResult: ARHitTestResult) {
        //if let selectedItem = self.selectedItem {
        let myURL = NSURL(string: model)
        // アセットのより、シーンを作成
        guard let scene = try? SCNScene(url: myURL! as URL, options: nil)else{return}
        //let scene = SCNScene(named: "art.scnassets/\(selectedItem).scn")
        let modelNode = SCNNode()
        //let node = (scene?.rootNode.childNode(withName: selectedItem, recursively: false))!
        for childNode in scene.rootNode.childNodes {
            modelNode.addChildNode(childNode)
        }
        
        // 現実世界の座標を取得
        let transform = hitTestResult.worldTransform
        let thirdColumn = transform.columns.3
        
        // アイテムの配置
        modelNode.position = SCNVector3(thirdColumn.x, thirdColumn.y, thirdColumn.z)
        modelNode.scale = SCNVector3(0.08,0.08,0.08)
        self.sceneView.scene.rootNode.addChildNode(modelNode)
        selectNode = modelNode
    }
    
    /*@IBAction func tap(_ sender: UITapGestureRecognizer) {
        let sceneView = sender.view as! ARSCNView
        let touchLocation = sender.location(in: sceneView)
        let hitResults = sceneView.hitTest(touchLocation, options: [SCNHitTestOption.searchMode : SCNHitTestSearchMode.all.rawValue])
        
        //タップ時にオブジェクトがあれば実行
        if let result = hitResults.first{
            guard let hitNodeName = result.node.name else {return}
            guard hitNodeName == "childfNodes" else {return}
            if let model = result.node.parent {
                selectNode = model
            }
        }
    }*/
    
    //拡大縮小
    @objc func scenePinchGesture(_ recognizer: UIPinchGestureRecognizer){
        var lastGestureScale: Float = 0.0
        if recognizer.state == .began {
            lastGestureScale = 0.1
        }
        let  newGestureScale: Float = Float(recognizer.scale)
        
        //ここで直前のscaleとdiffぶんだけ取得しておきます
        let diff = newGestureScale - lastGestureScale
        let currentScale = selectNode.scale
        
        //diff分だけscaleを変化させる。１は１倍、１.２は１.２倍になります
        selectNode.scale = SCNVector3Make(
            currentScale.x * diff,
            currentScale.y * diff,
            currentScale.z * diff
        )
        //保存しておく
        lastGestureScale = newGestureScale
    }
    
    /// QRコード読み取り画面に戻る
    @IBAction func ButtonTapped(_ sender: Any) {
        model = "global"
        CBcheck = true
        self.dismiss(animated: true, completion: nil)
    }
}

