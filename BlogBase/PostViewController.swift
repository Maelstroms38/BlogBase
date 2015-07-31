//
//  PostViewController.swift
//  BlogBase
//
//  Created by Michael Stromer on 10/18/14.
//  Copyright (c) 2014 Michael Stromer. All rights reserved.
//

import UIKit
import CoreData

class PostViewController: UIViewController, UITextFieldDelegate {
    @IBOutlet weak var textView: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        
        let url = NSURL(string:"https://www.googleapis.com/blogger/v3/3181080193230972557/posts?key=AIzaSyD-T4ANNqXR8L5RSsl8QrnlzGIet3JEHp0")
        let request = NSMutableURLRequest(URL: url!)
        var session = NSURLSession.sharedSession()
        request.HTTPMethod = "POST"
        request.setValue("application/json-rpc", forHTTPHeaderField: "Content-Type")
        
        var post: String
        textField.resignFirstResponder()
        post = textField.text
        println(post)
        
        let requestDictionary =
        [
            "kind": "blogger#post",
            "blog": [
                "id": "3181080193230972557"
            ],
            "title": "A new post",
            "content": post
        ] as NSDictionary
        
        var error: NSError?
        let requestBody = NSJSONSerialization.dataWithJSONObject(requestDictionary, options: nil, error: &error)
        if requestBody == nil {
            // completion(responseObject: nil, error: error)
            return false
        }
        
        request.HTTPBody = requestBody
        
        let task = session.dataTaskWithRequest(request) {
            data, response, error in
            
            // handle fundamental network errors (e.g. no connectivity)
            
            if error != nil {
                // completion(responseObject: data, error: error)
                return
            }
            
            // parse the JSON response
            
            var parseError: NSError?
            let responseObject = NSJSONSerialization.JSONObjectWithData(data, options: nil, error: &parseError) as? NSDictionary
            
            if responseObject == nil {
                
                // because it's not JSON, let's convert it to a string when we report completion (likely HTML or text)
                
                let responseString = NSString(data: data, encoding: NSUTF8StringEncoding) as! String
                // completion(responseObject: responseString, error: parseError)
                return
            }
            
            // completion(responseObject: responseObject, error: nil)
        }
        task.resume()
        
        return true
    }
}