//
//  MapController.swift
//  GopleCustomer
//
//  Created by 김민주 on 2017. 11. 14..
//  Copyright © 2017년 김민주. All rights reserved.
//

import UIKit
import WebKit
import MapKit

class MapController: UIViewController, UIScrollViewDelegate {
    
    var wkWebView = WKWebView()
    
    var viewNavBar = UIView()
    
    var textfield = UITextField()
    
    var searchbar = UISearchBar()
    
    let locationManager = CLLocationManager()
    
    let lat = UserDefaults.standard.object(forKey: "lat") as! String
    let lon = UserDefaults.standard.object(forKey: "lon") as! String

    override func viewDidLoad() {
        let controller = WKUserContentController()
        
        let configuration = WKWebViewConfiguration()
        configuration.userContentController = controller
        
        wkWebView = WKWebView(frame: self.view.frame, configuration: configuration)
        
        wkWebView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        wkWebView.scrollView.isScrollEnabled = false
        wkWebView.scrollView.bounces = true
        wkWebView.uiDelegate = self
        wkWebView.navigationDelegate = self
        
        let url = URL(string: domain + mapURL)
        var request = URLRequest(url: url!)
        request.httpMethod = "POST"
        let postString = "lat=\(lat)&lon=\(lon)"
        request.httpBody = postString.data(using: .utf8)
        wkWebView.load(request)
        self.view.addSubview(wkWebView)
        
        wkWebView.translatesAutoresizingMaskIntoConstraints = false
        wkWebView.topAnchor.constraint(equalTo: self.view.topAnchor, constant : 14).isActive = true
        wkWebView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
        wkWebView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
        wkWebView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
      
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        createNavigationBar()
        
        UIApplication.shared.statusBarStyle = .default
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return nil
    }

}

extension MapController : CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        CLGeocoder().reverseGeocodeLocation(manager.location!, completionHandler: {(placemarks, error)->Void in
            
            if (error != nil) {
                print("Error: \(error)")
                return
            }
            
            if placemarks!.count > 0 {
                let pm = placemarks![0]
                self.displayLocationInfo(placemark: pm)
            } else {
                print("Error with the data.")
            }
        })
        
    }
    
    func displayLocationInfo(placemark: CLPlacemark) {
        
        self.locationManager.stopUpdatingLocation()
        
        print("위도 : \(String(describing: placemark.location?.coordinate.latitude)) / 경도 : \(String(describing: placemark.location?.coordinate.longitude))")
        
        let lat = String(describing: placemark.location!.coordinate.latitude)
        let lon = String(describing: placemark.location!.coordinate.longitude)
        
        UserDefaults.standard.set(lat, forKey: "lat")
        UserDefaults.standard.set(lon, forKey: "lon")
        
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
    }
}

extension MapController {
    func createNavigationBar() {
        viewNavBar = UIView(frame: CGRect(
            origin: CGPoint(x: 0, y: 0),
            size: CGSize(width: self.view.frame.size.width, height: 58)))
        viewNavBar.backgroundColor = UIColor.white
        
        let backBtn = UIButton()
        backBtn.frame = CGRect(x: 9, y: 14, width: 42, height: 31)
        backBtn.setImage(#imageLiteral(resourceName: "back_black"), for: .normal)
        backBtn.addTarget(self, action: #selector(doneBtn(_:)), for: .touchUpInside)
        viewNavBar.addSubview(backBtn)
        
        let title = UILabel()
        title.text = "스튜디오"
        title.font = UIFont(name: "DaeHan-Bold", size: 20)
        title.textColor = textColor
        title.frame = CGRect(x: 0, y: 20, width: 140, height: 20)
        title.center.x = self.view.frame.width / 2
        title.textAlignment = .center
        viewNavBar.addSubview(title)
        
        let search = UIButton()
        search.setImage(#imageLiteral(resourceName: "search_black"), for: .normal)
        search.addTarget(self, action: #selector(goSearch(_:)), for: .touchUpInside)
        search.frame = CGRect(origin: CGPoint(x: 0, y: 7), size: CGSize(width: 35, height: 44))
        search.frame.origin.x = self.view.frame.width - (12 + search.frame.width)
        viewNavBar.addSubview(search)
        
        self.navigationController?.navigationBar.addSubview(viewNavBar)
    }
    
    func goSearch(_ sender: UIButton){
        if let searchVC = self.storyboard?.instantiateViewController(withIdentifier: "SearchViewController") as? NavigationController {
            SearchViewController.route = "defalut"
            self.present(searchVC, animated: true, completion: nil)
        }
        
    }
    
    func showMenu(_ sender: UIButton) {
        if let hamburgerVC = self.storyboard?.instantiateViewController(withIdentifier: "HamburgerController") as? HamburgerController {
            self.present(hamburgerVC, animated: true, completion: nil)
        }
    }
    
    func doneBtn(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
        viewNavBar.removeFromSuperview()
    }
}

extension MapController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, runJavaScriptAlertPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping () -> Void) {
        let alertController = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        let otherAction = UIAlertAction(title: "확인", style: .default) {
            action in completionHandler()
        }
        alertController.addAction(otherAction)
        present(alertController, animated: true, completion: nil)
    }
    
    func webView(_ webView: WKWebView, runJavaScriptConfirmPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping (Bool) -> Void) {
        let alertController = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "취소", style: .cancel) {
            action in completionHandler(false)
        }
        let okAction = UIAlertAction(title: "확인", style: .default) {
            action in completionHandler(true)
        }
        alertController.addAction(cancelAction)
        alertController.addAction(okAction)
        present(alertController, animated: true, completion: nil)
    }
    
    func webView(_ webView: WKWebView, runJavaScriptTextInputPanelWithPrompt prompt: String, defaultText: String?, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping (String?) -> Void) {
        
        let alertController = UIAlertController(title: nil, message: prompt, preferredStyle: .alert)
        let okHandler: () -> Void = { handler in
            if let textField = alertController.textFields?.first {
                completionHandler(textField.text)
            } else {
                completionHandler("")
            }
        }
        let cancelAction = UIAlertAction(title: "취소", style: .cancel) {
            action in completionHandler(nil)
        }
        let okAction = UIAlertAction(title: "확인", style: .default) {
            action in okHandler()
        }
        alertController.addTextField { $0.text = defaultText }
        alertController.addAction(cancelAction)
        alertController.addAction(okAction)
        present(alertController, animated: true, completion: nil)
    }
}

extension MapController: WKUIDelegate {
    
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        
        wkWebView.isUserInteractionEnabled = false
        
        // 2. 상단 status bar에도 activity indicator가 나오게 할 것이다.
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        wkWebView.isUserInteractionEnabled = true
        
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
        
    }
    
}
