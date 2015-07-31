//
//  DetailViewController.swift
//  BlogBase
//
//  Created by Michael Stromer on 9/23/14.
//  Copyright (c) 2014 Michael Stromer. All rights reserved.
//

import UIKit
import Social

class DetailViewController: UIViewController, MediumScrollFullScreenDelegate, UIGestureRecognizerDelegate, UIScrollViewDelegate {
    
    enum State {
        case Showing
        case Hiding
        case Default
    }
    @IBOutlet weak var webView: UIWebView!
    
    var statement: State = .Hiding
    var scrollProxy: MediumScrollFullScreen?
    var scrollView: UIScrollView?
    var enableTap: Bool = false
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        hideToolbar(true)
    }
    
    var detailItem: AnyObject? {
        didSet {
            // Update the view.
            self.configureView()
        }
    }
    
    func configureView() {
        // Update the user interface for the detail item.
        
        
        webView.loadHTMLString(activeItem, baseURL: nil)
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        scrollProxy = MediumScrollFullScreen(forwardTarget: webView)
        webView.scrollView.delegate = scrollProxy
        scrollProxy?.delegate = self as MediumScrollFullScreenDelegate
        // Do any additional setup after loading the view, typically from a nib.
        let screenTap = UITapGestureRecognizer(target: self, action: "tapGesture:")
        screenTap.numberOfTapsRequired = 1
        screenTap.delegate = self
        webView.addGestureRecognizer(screenTap)
        // Add temporary item
        
//        title = "Title"
//        navigationItem.hidesBackButton = true
        
        let menuColor = UIColor(red:0.2, green:0.2, blue:0.2, alpha:1)
        
//        let backButton = UIBarButtonItem(image: UIImage(named: "back_arrow"), style: UIBarButtonItemStyle.Plain, target: self, action: "popView")
//        backButton.tintColor = menuColor
//        navigationItem.leftBarButtonItem = backButton
        
        let rightButton = UIButton.buttonWithType(UIButtonType.Custom) as! UIButton
        rightButton.frame = CGRectMake(0, 0, 60, 60)
        rightButton.addTarget(self, action: "changeIcon:", forControlEvents: UIControlEvents.TouchUpInside)
        rightButton.setImage(UIImage(named: "star_n"), forState: UIControlState.Normal)
        rightButton.setImage(UIImage(named: "star_s"), forState: UIControlState.Selected)
        let barItem: UIBarButtonItem = UIBarButtonItem(customView: rightButton)
        navigationItem.rightBarButtonItem = barItem
        
        let favButton = UIButton.buttonWithType(UIButtonType.Custom) as! UIButton
        favButton.frame = CGRectMake(0, 0, 60, 60)
        favButton.addTarget(self, action: "changeIcon:", forControlEvents: UIControlEvents.TouchUpInside)
        favButton.setImage(UIImage(named: "fav_n"), forState: UIControlState.Normal)
        favButton.setImage(UIImage(named: "fav_s"), forState: UIControlState.Selected)
        let toolItem: UIBarButtonItem = UIBarButtonItem(customView: favButton)
        
        let timeLabel = UILabel(frame: CGRectMake(0, 0, 100, 20))
        timeLabel.text = "5 mins left"
        timeLabel.textAlignment = .Center
        timeLabel.tintColor = menuColor
        let timeView = timeLabel as UIView
        let timeButton = UIBarButtonItem(customView: timeView)
        
        let actionButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Action, target: nil, action: "share")
        actionButton.tintColor = menuColor
        
        let gap = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FlexibleSpace, target: nil, action: nil)
        let fixedSpace = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FixedSpace, target: nil, action: nil)
        fixedSpace.width = 20
        toolbarItems = [toolItem, gap, timeButton, gap, actionButton, fixedSpace]
        
        self.configureView()
        
    }
    func changeIcon(sender: UIButton) {
        let btn = sender
        if btn.selected == true {
            btn.selected = false
        } else {
            btn.selected = true
        }
    }
    
    func share() {
        
        //Generate the screenshot
        UIGraphicsBeginImageContext(view.frame.size)
        view.layer.renderInContext(UIGraphicsGetCurrentContext())
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        let shareToFacebook = SLComposeViewController(forServiceType:
            SLServiceTypeFacebook)
        shareToFacebook.setInitialText("Check out Maestro's Blog at: http://www.michaelstromer.me")
        shareToFacebook.addImage(image)
        presentViewController(shareToFacebook, animated: true, completion: nil)
    }
    func popView() {
        navigationController?.popViewControllerAnimated(true)
    }
    
    func tapGesture(sender: UITapGestureRecognizer) {
        if enableTap {
            if statement == .Hiding {
                if navigationController?.toolbarHidden == true {
                    UIView.animateWithDuration(0.3, animations: {[unowned self]() -> () in
                        self.navigationController!.toolbarHidden = false
                    })
                }
                showNavigationBar(true)
                showToolbar(true)
                statement = .Showing
            } else {
                hideNavigationBar(true)
                hideToolbar(true)
                statement = .Hiding
            }
        }
    }
    
    func gestureRecognizerShouldBegin(gestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    // MediumMenuInFullScreenDelegate
    
    func scrollFullScreen(fullScreenProxy: MediumScrollFullScreen, scrollViewDidScrollUp deltaY: Float, userInteractionEnabled enabled: Bool) {
        if enabled {
            enableTap = false
        } else {
            enableTap = true
        }
        moveNavigationBar(deltaY: deltaY, animated: true)
        moveToolbar(deltaY: -deltaY, animated: true)
    }
    
    func scrollFullScreen(fullScreenProxy: MediumScrollFullScreen, scrollViewDidScrollDown deltaY: Float, userInteractionEnabled enabled: Bool) {
        if enabled {
            enableTap = false
            moveNavigationBar(deltaY: deltaY, animated: true)
            hideToolbar(true)
        } else {
            enableTap = true
            moveNavigationBar(deltaY: -deltaY, animated: true)
            moveToolbar(deltaY: deltaY, animated: true)
        }
    }
    
    func scrollFullScreenScrollViewDidEndDraggingScrollUp(fullScreenProxy: MediumScrollFullScreen, userInteractionEnabled enabled: Bool) {
        hideNavigationBar(true)
        hideToolbar(true)
        statement = .Hiding
    }
    
    func scrollFullScreenScrollViewDidEndDraggingScrollDown(fullScreenProxy: MediumScrollFullScreen, userInteractionEnabled enabled: Bool) {
        if enabled {
            showNavigationBar(true)
            hideToolbar(true)
            statement = .Showing
        } else {
            hideNavigationBar(true)
            hideToolbar(true)
            statement = .Hiding
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}
extension String {
    /// Truncates the string to length number of characters and
    /// appends optional trailing string if longer
    func truncate(length: Int, trailing: String? = nil) -> String {
        if count(self) > length {
            return self.substringToIndex(advance(self.startIndex, length)) + (trailing ?? "")
        } else {
            return self
        }
    }
}


