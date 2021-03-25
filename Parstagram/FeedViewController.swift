//
//  FeedViewController.swift
//  Parstagram
//
//  Created by Liberty Mupotsa on 3/17/21.
//

import UIKit
import Parse
import AlamofireImage
class FeedViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    var numberOfPosts = 10
    var posts = [PFObject]()
    let myRefreshControl = UIRefreshControl()
    @IBOutlet weak var tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        myRefreshControl.tintColor = .yellow
        myRefreshControl.addTarget(self, action: #selector(viewDidAppear(_:)), for: .valueChanged)
        tableView.refreshControl = myRefreshControl

        // Do any additional setup after loading the view.
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        
        let query = PFQuery(className: "Posts")
        query.order(byDescending: "updatedAt")
        query.includeKey("author")
        query.limit = numberOfPosts
        
        query.findObjectsInBackground { (posts, error) in
            if posts != nil {
                self.posts = posts!
                self.tableView.reloadData()
            }
            
            self.myRefreshControl.endRefreshing()
        }
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let post = posts[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "PostCell") as! PostCell
        let user = post["author"] as! PFUser
        cell.captionLabel.text = post["caption"] as! String
        cell.usernameLabel.text = user.username
        let imageFile = post["image"] as! PFFileObject
        let urlString = imageFile.url!
        let url = URL(string: urlString)!
        cell.photoView.af_setImage(withURL: url)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let post = posts[indexPath.row]
        
        // creating a comment object
        let comment = PFObject(className: "Comments")
        comment["text"] = "This is a random comment"
        comment["post"] = post
        comment["author"] = PFUser.current()!
        
        post.add(comment,forKey: "comments")
        
        post.saveInBackground { (success, error) in
            if success {
                print("Comment saved")
            } else {
            print("Error in saving the post")
        }
    }
    }
    func loadMorePosts(){
        
        let query = PFQuery(className: "Posts")
        query.order(byDescending: "updatedAt")
        query.includeKey("author")
        numberOfPosts = numberOfPosts + 10
        query.limit = numberOfPosts
        
        query.findObjectsInBackground { (posts, error) in
            if posts != nil {
                self.posts = posts!
                self.tableView.reloadData()
            }
        }
        
    }
    
     func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row + 1 == posts.count{
            loadMorePosts()
            print("Loaded new Posts beyond the given one.")
        }
    }
    
    

    @IBAction func onLogout(_ sender: Any) {
        PFUser.logOut()
        
        let main = UIStoryboard(name: "Main", bundle: nil)
        let loginViewController = main.instantiateViewController(withIdentifier: "LoginViewController")
        let delegate = self.view.window?.windowScene?.delegate as! SceneDelegate
        delegate.window?.rootViewController = loginViewController
    }
}

