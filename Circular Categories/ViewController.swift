//
//  ViewController.swift
//  Circular Categories
//
//  Created by Brian Cao on 2/7/19.
//  Copyright © 2019 Brian Cao. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.layoutIfNeeded()
    
        let circleCategory = BCCircularCategory(interCircleRadius: 60, outerCircleRadius: 75)
        circleCategory.addOuterCircleButton(imageNamed: "testimage", action: {})
        circleCategory.addOuterCircleButton(imageNamed: "testimage", action: {})
        circleCategory.addOuterCircleButton(imageNamed: "testimage", action: {})
        circleCategory.addOuterCircleButton(imageNamed: "testimage", action: {})
        circleCategory.addOuterCircleButton(imageNamed: "testimage", action: {})
        circleCategory.addOuterCircleButton(imageNamed: "testimage", action: {})
        circleCategory.addOuterCircleButton(imageNamed: "testimage", action: {})
        
        self.view.addSubview(circleCategory)
        circleCategory.center = view.center
    }
}

struct BCCircle {
    let center: CGPoint
    let radius: CGFloat

    func pointOnCircle(angle: CGFloat) -> CGPoint {
        let x = center.x + radius * cos(angle)
        let y = center.y + radius * sin(angle)

        return CGPoint(x: x, y: y)
    }

    func angleBetween(firstPoint: CGPoint, secondPoint: CGPoint) -> CGFloat {
        let firstAngle = atan2(firstPoint.y - center.y, firstPoint.x - center.x)
        let secondAngle = atan2(secondPoint.y - center.y, secondPoint.x - center.x)
        let angleDiff = (firstAngle - secondAngle) * -1

        return angleDiff
    }
}


class BCRotatingButton: UIButton{
    var currentAngle: CGFloat = 0
    var circle: BCCircle
    var action: () -> Void

    init(imageNamed imageName: String, action: @escaping () -> Void , circle: BCCircle, radius: CGFloat) {
        
        self.circle = circle
        self.action = action
        super.init(frame: CGRect(x: 0, y: 0, width: radius * 2, height: radius * 2))
        isUserInteractionEnabled = true
        setImage(UIImage(named: imageName), for: .normal)
        layer.cornerRadius = min(self.frame.size.height, self.frame.size.width) / 2.0
        clipsToBounds = true
        
    
        center = circle.pointOnCircle(angle: currentAngle)
        backgroundColor = .blue
        
        addTarget(self, action: #selector(self.touched), for: .touchUpInside)

    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var collisionBoundsType: UIDynamicItemCollisionBoundsType{
        return .ellipse
    }
    
    @objc func touched(){
        action()
    }
    func updatePosition(angle: CGFloat) {
        currentAngle += angle
        center = circle.pointOnCircle(angle: currentAngle)
    }
    
    func updateAngle(angle: CGFloat) {
        currentAngle = angle
        center = circle.pointOnCircle(angle: angle)
    }

}

class BCCircleButton: UIButton {
    
    var action: () -> Void
    init(imageNamed imageName: String, action: @escaping () -> Void, radius: CGFloat) {
        self.action = action
        super.init(frame: CGRect(x: 0, y: 0, width: radius * 2, height: radius * 2))
        isUserInteractionEnabled = true
        setImage(UIImage(named: imageName), for: .normal)
        layer.cornerRadius = min(self.frame.size.height, self.frame.size.width) / 2.0
        clipsToBounds = true
        
        
        addTarget(self, action: #selector(self.touched), for: .touchUpInside)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var collisionBoundsType: UIDynamicItemCollisionBoundsType{
        return .ellipse
    }
    
    @objc func touched(){
        action()
    }
    
}


class BCCircularCategory: UIView{
    let interCircleRadius: CGFloat
    let outerCircleRadius: CGFloat
   
    var rotatingViews = [BCRotatingButton]()
    var animator: UIDynamicAnimator!
    var circle: BCCircle!
    var beginningLocation = CGPoint.zero
    var beginningAngle: CGFloat!
    var snap: UISnapBehavior!
    
    var collision = UICollisionBehavior()
    
    init(interCircleRadius: CGFloat, outerCircleRadius: CGFloat) {
        self.interCircleRadius = interCircleRadius
        self.outerCircleRadius = outerCircleRadius
        let frameSize = 2 * (interCircleRadius + outerCircleRadius * 2 + 10)
        
        super.init(frame: CGRect(x: 0, y: 0, width: frameSize, height: frameSize))
        
        animator = UIDynamicAnimator(referenceView: self)
        
        let interCircle = BCCircleButton(imageNamed: "testimage", action: {}, radius: interCircleRadius)
        interCircle.center = center
        interCircle.backgroundColor = .red
        self.addSubview(interCircle)
        
        animator.addBehavior(collision)
        
        collision.addBoundary(withIdentifier: "innerCircle" as NSCopying, for: UIBezierPath(ovalIn: interCircle.frame))
        
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func addOuterCircleButton(imageNamed imageName: String, action: @escaping () -> Void){
       
       
        // intercircle radius, outercircle radius, number of outer circles
        
        // Update circle based on new number of outerCircles
        let radius = ((outerCircleRadius * CGFloat(2 * rotatingViews.count + 1))/(CGFloat.pi))/1.5
        circle = BCCircle(center: self.center, radius: radius)
        
        // Update angleBetweenViews based on new number of outerCircles
        let angleBetweenViews = (2 * CGFloat.pi) / CGFloat(rotatingViews.count + 1)
        
        // Add new rotatingButton
        let viewOnCircle = BCRotatingButton(imageNamed: imageName, action: action, circle: circle, radius: outerCircleRadius)
        rotatingViews.append(viewOnCircle)
   
        // Update old buttons
        for i in 0...rotatingViews.count - 1 {
            rotatingViews[i].circle = circle
            rotatingViews[i].updateAngle(angle: CGFloat(i) * angleBetweenViews)
            animator.updateItem(usingCurrentState: rotatingViews[i])
        }

        self.addSubview(viewOnCircle)
        
        collision.addItem(viewOnCircle)
        
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(didPan(panGesture:)))
        viewOnCircle.addGestureRecognizer(panGesture)
    }
    
    
    @objc func didPan(panGesture: UIPanGestureRecognizer){
   
        let view = panGesture.view!
        
        if view is BCRotatingButton{
            let pannedView = view as! BCRotatingButton
            switch panGesture.state {
                
            case .began:
                if snap != nil {
                    animator.removeBehavior(snap)
                }
                
                beginningLocation = pannedView.center
                beginningAngle = pannedView.currentAngle
                animator.updateItem(usingCurrentState: pannedView)
            case .changed:
                pannedView.center = panGesture.location(in: self)
                let angleDifference = circle.angleBetween(firstPoint: beginningLocation, secondPoint: panGesture.location(in: self))
                for view in rotatingViews {
                    if(view != pannedView){
                        view.updatePosition(angle: angleDifference)
                        
                        animator.updateItem(usingCurrentState: view)
                    }
                }
                beginningLocation = panGesture.location(in: self)
                animator.updateItem(usingCurrentState: pannedView)
            case .ended:
                
                let firstPoint = circle.pointOnCircle(angle: beginningAngle)
                let angleDifference = circle.angleBetween(firstPoint: firstPoint, secondPoint: panGesture.location(in: self))
                
                let snapLocation = circle.pointOnCircle(angle: beginningAngle + angleDifference)
                
                snap = UISnapBehavior(item: pannedView, snapTo: snapLocation)
                animator.addBehavior(snap)
                for view in rotatingViews {
                    if view != pannedView{
//                        if snap != nil {
//                            animator.removeBehavior(snap)
//                        }
                        snap = UISnapBehavior(item: view, snapTo: view.center)
                        animator.addBehavior(snap)
                    }
                }
                
                animator.updateItem(usingCurrentState: pannedView)
                pannedView.currentAngle += angleDifference
                
                
            default:
                break
            }
            
        }
        
    }
}
