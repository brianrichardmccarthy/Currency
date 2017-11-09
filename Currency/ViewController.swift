//
//  ViewController.swift
//  Currency
//
//  Created by Robert O'Connor on 18/10/2017.
//  Copyright © 2017 WIT. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITextFieldDelegate {
    
    //MARK Model holders
    var currencyDict:Dictionary = [String:Currency]()
    var currencyArray = [Currency]()
    var baseCurrency:Currency = Currency.init(name:"EUR", rate:1, flag:"🇪🇺", symbol:"€")!
    var lastUpdatedDate:Date = Date()
    
    var convertValue:Double = 0
    
    //MARK Outlets
    //@IBOutlet weak var convertedLabel: UILabel!
    @IBOutlet var scrollView: UIScrollView!
    
    @IBOutlet weak var baseSymbol: UILabel!
    @IBOutlet weak var baseTextField: UITextField!
    @IBOutlet weak var baseFlag: UILabel!
    @IBOutlet weak var lastUpdatedDateLabel: UILabel!
    
    @IBOutlet weak var gbpSymbolLabel: UILabel!
    @IBOutlet weak var gbpValueLabel: UILabel!
    @IBOutlet weak var gbpFlagLabel: UILabel!
    
    @IBOutlet weak var usdSymbolLabel: UILabel!
    @IBOutlet weak var usdValueLabel: UILabel!
    @IBOutlet weak var usdFlagLabel: UILabel!
    
    @IBOutlet weak var firstExtraSymbol: UILabel!
    @IBOutlet weak var firstExtraValue: UILabel!
    @IBOutlet weak var firstExtraFlag: UILabel!
    
    @IBOutlet weak var seondExtraSymbol: UILabel!
    @IBOutlet weak var secondExtraValue: UILabel!
    @IBOutlet weak var secondExtraFlag: UILabel!
    
    @IBOutlet weak var thirdExtraSymbol: UILabel!
    @IBOutlet weak var thirdExtraValue: UILabel!
    @IBOutlet weak var thirdExtraFlag: UILabel!
    
    @IBOutlet weak var fourthExtraSymbol: UILabel!
    @IBOutlet weak var fourthExtraValue: UILabel!
    @IBOutlet weak var fourthExtraFlag: UILabel!
    
    func doneClicked() {
        view.endEditing(true)
    }
    
    /*
    func baseTextFieldWillAppear(notication: NSNotification) {
        baseTextField.text = ""
        self.scrollView.isScrollEnabled = true
        var info = notication.userInfo!
        let keyoardSize = (info[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue.size
        let contentInsets : UIEdgeInsets = UIEdgeInsetsMake(0.0, 0.0, keyoardSize!.height, 0.0)
        
        self.scrollView.contentInset = contentInsets
        self.scrollView.scrollIndicatorInsets = contentInsets
        var aRect : CGRect = self.view.frame
        aRect.size.height -= keyoardSize!.height
        if let activeField = self.baseTextField {
            if (!aRect.contains(activeField.frame.origin)) {
                self.scrollView.scrollRectToVisible(activeField.frame, animated: true)
            }
        }
        
    }
    
    func baseTextFieldWillDisappear(notication: NSNotification) {
        // ToDo convert
        var info = notication.userInfo!
        let keyoardSize = (info[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue.size
        let contentInsets : UIEdgeInsets = UIEdgeInsetsMake(0.0, 0.0, -keyoardSize!.height, 0.0)
        self.scrollView.contentInset = contentInsets
        self.scrollView.scrollIndicatorInsets = contentInsets
        self.scrollView.isScrollEnabled = false
    }
    */
    
    func keyboardWasShown(notification: NSNotification){
        baseTextField.text = ""
        self.scrollView.isScrollEnabled = true
        var info = notification.userInfo!
        let keyboardSize = (info[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue.size
        let contentInsets : UIEdgeInsets = UIEdgeInsetsMake(0.0, 0.0, keyboardSize!.height, 0.0)
        
        self.scrollView.contentInset = contentInsets
        self.scrollView.scrollIndicatorInsets = contentInsets
        
        var aRect : CGRect = self.view.frame
        aRect.size.height -= keyboardSize!.height
        if let activeField = self.baseTextField {
            if (!aRect.contains(activeField.frame.origin)){
                self.scrollView.scrollRectToVisible(activeField.frame, animated: true)
            }
        }
    }
    
    func keyboardWillBeHidden(notification: NSNotification){
        var info = notification.userInfo!
        let keyboardSize = (info[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue.size
        let contentInsets : UIEdgeInsets = UIEdgeInsetsMake(0.0, 0.0, -keyboardSize!.height, 0.0)
        self.scrollView.contentInset = contentInsets
        self.scrollView.scrollIndicatorInsets = contentInsets
        self.view.endEditing(true)
        self.scrollView.isScrollEnabled = false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        // print("currencyDict has \(self.currencyDict.count) entries")
        
        // scrollView.contentSize = CGSize(width: self.view.frame.size.width*2, height: 700)
        scrollView.contentSize.height = 700
        
        // create currency dictionary
        self.createCurrencyDictionary()
        
        // get latest currency values
        getConversionTable()
        // getConversionTableUpdated()
        convertValue = 1
        
        // set up base currency screen items
        baseTextField.text = String(format: "%.02f", baseCurrency.rate)
        baseSymbol.text = baseCurrency.symbol
        baseFlag.text = baseCurrency.flag
        
        // set up last updated date
        let dateformatter = DateFormatter()
        dateformatter.dateFormat = "dd/MM/yyyy hh:mm a"
        lastUpdatedDateLabel.text = "Last Updated: \(dateformatter.string(from: lastUpdatedDate))"
        
        // display currency info
        self.displayCurrencyInfo()
        
        
        // setup view mover
        baseTextField.delegate = self
        
        self.convert(self)
        
        
        let toolbar = UIToolbar()
        
        toolbar.sizeToFit()
        
        let doneButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.done, target: self, action: #selector(self.doneClicked))
        
        toolbar.setItems([doneButton], animated: false)
        
        baseTextField.inputAccessoryView = toolbar
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWasShown(notification:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillBeHidden(notification:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        //NotificationCenter.default.addObserver(self, selector: #selector(baseTextFieldWillAppear(notification:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        
        // NotificationCenter.default.addObserver(self, selector: #selector(keyboardWasShown(notification:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        //NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillBeHidden(notification:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        // NotificationCenter.default.addObserver(self, selector: #selector(ViewController.baseTextFieldWillAppear(notification:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        // NotificationCenter.default.addObserver(self, selector: #selector(baseTextFieldWillDisappear(notification:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func createCurrencyDictionary(){
        //let c:Currency = Currency(name: name, rate: rate!, flag: flag, symbol: symbol)!
        //self.currencyDict[name] = c
        currencyDict["GBP"] = Currency(name:"GBP", rate:1, flag:"🇬🇧", symbol: "£")
        currencyDict["USD"] = Currency(name:"USD", rate:1, flag:"🇺🇸", symbol: "$")
        currencyDict["BGN"] = Currency(name:"BGN", rate:1, flag:"🇧🇬", symbol:"лв")
        currencyDict["CZK"] = Currency(name:"CZK", rate:1, flag:"🇨🇿", symbol:"Kč")
        currencyDict["DKK"] = Currency(name:"DKK", rate:1, flag:"🇩🇰", symbol:"kr")
        currencyDict["SEK"] = Currency(name:"SEK", rate:1, flag:"🇸🇪", symbol:"kr")
    }
    
    func displayCurrencyInfo() {
        // GBP
        if let c = currencyDict["GBP"]{
            gbpSymbolLabel.text = c.symbol
            gbpValueLabel.text = String(format: "%.02f", c.rate)
            gbpFlagLabel.text = c.flag
        }
        if let c = currencyDict["USD"]{
            usdSymbolLabel.text = c.symbol
            usdValueLabel.text = String(format: "%.02f", c.rate)
            usdFlagLabel.text = c.flag
        }
        
        if let c = currencyDict["BGN"] {
            firstExtraSymbol.text = c.symbol
            firstExtraValue.text = String(format: "%.02f", c.rate)
            firstExtraFlag.text = c.flag
        }
        
        if let c = currencyDict["DKK"] {
            seondExtraSymbol.text = c.symbol
            secondExtraValue.text = String(format: "%.02f", c.rate)
            secondExtraFlag.text = c.flag
        }
        
        if let c = currencyDict["CZK"] {
            thirdExtraSymbol.text = c.symbol
            thirdExtraValue.text = String(format: "%.02f", c.rate)
            thirdExtraFlag.text = c.flag
        }
        
        if let c = currencyDict["SEK"] {
            fourthExtraSymbol.text = c.symbol
            fourthExtraValue.text = String(format: "%.02f", c.rate)
            fourthExtraFlag.text = c.flag
        }
    }
    
    func getConversionTable() {
        //var result = "<NOTHING>"
        
        let urlStr:String = "https://api.fixer.io/latest"
        
        var request = URLRequest(url: URL(string: urlStr)!)
        request.httpMethod = "GET"
        
        customAcitivityIndicator()
        
        NSURLConnection.sendAsynchronousRequest(request, queue: OperationQueue.main) { response, data, error in
            // print(data?.count)
        
            self.customAcitivityIndicator(startAnimate: false)
            
            if error == nil{
                //print(response!)
                
                do {
                    let jsonDict = try JSONSerialization.jsonObject(with: data!, options: .mutableContainers) as! [String:Any]
                    //print(jsonDict)
                    
                    if let ratesData = jsonDict["rates"] as? NSDictionary {
                        //print(ratesData)
                        for rate in ratesData{
                            //print("#####")
                            let name = String(describing: rate.key)
                            let rate = (rate.value as? NSNumber)?.doubleValue
                            //var symbol:String
                            //var flag:String
                            
                            switch(name){
                            case "USD":
                                //symbol = "$"
                                //flag = "🇺🇸"
                                let c:Currency  = self.currencyDict["USD"]!
                                c.rate = rate!
                                self.currencyDict["USD"] = c
                            case "GBP":
                                //symbol = "£"
                                //flag = "🇬🇧"
                                let c:Currency  = self.currencyDict["GBP"]!
                                c.rate = rate!
                                self.currencyDict["GBP"] = c
                            case "BGN":
                                //symbol = "£"
                                //flag = "🇬🇧"
                                let c:Currency  = self.currencyDict["GBP"]!
                                c.rate = rate!
                                self.currencyDict["BGN"] = c
                            case "DKK":
                                //symbol = "£"
                                //flag = "🇬🇧"
                                let c:Currency  = self.currencyDict["DKK"]!
                                c.rate = rate!
                                self.currencyDict["DKK"] = c
                            case "CZK":
                                //symbol = "£"
                                //flag = "🇬🇧"
                                let c:Currency  = self.currencyDict["CZK"]!
                                c.rate = rate!
                                self.currencyDict["CZK"] = c
                            case "SEK":
                                //symbol = "£"
                                //flag = "🇬🇧"
                                let c:Currency  = self.currencyDict["SEK"]!
                                c.rate = rate!
                                self.currencyDict["SEK"] = c
                            default:
                                print("Ignoring currency: \(String(describing: rate))")
                            }
                            
                            /*
                             let c:Currency = Currency(name: name, rate: rate!, flag: flag, symbol: symbol)!
                             self.currencyDict[name] = c
                             */
                        }
                        self.lastUpdatedDate = Date()
                    }
                }
                catch let error as NSError{
                    print(error)
                }
            }
            else{
                print("Error")
            }
            
        }
        
    }
    
    /*
    func getConversionTable() {
        //var result = "<NOTHING>"
        
        // let url = URL(String: "https://api.fixer.io/latest")
        
        let url = URL(string: "https://api.fixer.io/latest")!
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                DispatchQueue.main.async {
                    print("Error: \(error.localizedDescription)")
                }
                return
            }
            let data = data!
            
            guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
                DispatchQueue.main.async {
                    print("`Sever Error")
                }
                return
            }
            
            if response.mimeType == "application/json",
                let string = String (data: data, encoding: .utf8) {
                DispatchQueue.main.async {
                    self.
                }
            }
        }
        task.resume()
    }
    
    func parseJSON(var json) {
    }
    */
    
    func getConversionTableUpdated() {
        customAcitivityIndicator()
        let url = URL(string: "https://api.fixer.io/latest")!
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            self.customAcitivityIndicator(startAnimate: false)
            if let error = error {
                DispatchQueue.main.async {
                    print("Error: \(error.localizedDescription)")
                }
                return
            }
            let data = data!
            
            guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
                DispatchQueue.main.async {
                    print("Server Error")
                }
                return
            }
            
            if response.mimeType == "application/json",
                let string = String (data: data, encoding: .utf8) {
                DispatchQueue.main.async {
                    // self.textView.text = string
                    print("All Good")
                    print(data.count)
                    /*
                    do {
                        let jsonDict = try JSONSerialization.jsonObject(with: data!, options: .mutableContainers) as! [String:Any]
                        //print(jsonDict)
                        
                        if let ratesData = jsonDict["rates"] as? NSDictionary {
                            //print(ratesData)
                            for rate in ratesData{
                                //print("#####")
                                let name = String(describing: rate.key)
                                let rate = (rate.value as? NSNumber)?.doubleValue
                                //var symbol:String
                                //var flag:String
                                
                                switch(name){
                                case "USD":
                                    //symbol = "$"
                                    //flag = "🇺🇸"
                                    let c:Currency  = self.currencyDict["USD"]!
                                    c.rate = rate!
                                    self.currencyDict["USD"] = c
                                case "GBP":
                                    //symbol = "£"
                                    //flag = "🇬🇧"
                                    let c:Currency  = self.currencyDict["GBP"]!
                                    c.rate = rate!
                                    self.currencyDict["GBP"] = c
                                default:
                                    print("Ignoring currency: \(String(describing: rate))")
                                }
                                
                                /*
                                 let c:Currency = Currency(name: name, rate: rate!, flag: flag, symbol: symbol)!
                                 self.currencyDict[name] = c
                                 */
                            }
                            self.lastUpdatedDate = Date()
                        }
                        
                    }
                    catch let error as NSError {
                        print(error)
                    }
                 */
                }
            } else {
                print("\(response.mimeType)")
            }
        }
        task.resume()
    }
    
    @IBAction func refresh(_ sender: Any) {
        getConversionTable()
        baseTextField.text = "1.0"
        convert(sender)
    }
    
    @IBAction func convert(_ sender: Any) {
    
        var resultGBP = 0.0
        var resultUSD = 0.0
        
        var resultBGN = 0.0
        var resultCZK = 0.0
        var resultDKK = 0.0
        var resultSEK = 0.0
        
        if let euro = Double(baseTextField.text!) {
            convertValue = euro
            if let gbp = self.currencyDict["GBP"] {
                resultGBP = convertValue * gbp.rate
            }
            if let usd = self.currencyDict["USD"] {
                resultUSD = convertValue * usd.rate
            }
            
            if let bgn = self.currencyDict["BGN"] {
                resultBGN = convertValue * bgn.rate
            }
            
            if let czk = self.currencyDict["CZK"] {
                resultCZK = convertValue * czk.rate
            }
            
            if let dkk = self.currencyDict["DKK"] {
                resultDKK = convertValue * dkk.rate
            }
            
            if let sek = self.currencyDict["SEK"] {
                resultSEK = convertValue * sek.rate
            }
        }
        //GBP
        
        //convertedLabel.text = String(describing: resultGBP)
        
        gbpValueLabel.text = String(format: "%.02f", resultGBP)
        usdValueLabel.text = String(format: "%.02f", resultUSD)
    
        firstExtraValue.text = String(format: "%.02f", resultBGN) // BGN
        secondExtraValue.text = String(format: "%.02f", resultDKK) // DKK
        thirdExtraValue.text = String(format: "%.02f", resultCZK) // CZK
        fourthExtraValue.text = String(format: "%.02f", resultSEK) // SEK
        
    }
    
    /*
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     
     }
     */
    
    @discardableResult func customAcitivityIndicator(startAnimate:Bool? = true)  {
        let mainContainter: UIView = UIView(frame: self.view.frame)
        mainContainter.center = self.view.center
        mainContainter.backgroundColor = UIColor.init(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.5)
        mainContainter.tag = 789456123
        mainContainter.isUserInteractionEnabled = false
        
        let viewBackground: UIView = UIView(frame: CGRect(x:0,y:0, width:80,height:80))
        viewBackground.center = self.view.center
        viewBackground.backgroundColor = UIColor.init(red: 0.25, green: 0.25, blue: 0.25, alpha: 0.5)
        viewBackground.clipsToBounds = true
        viewBackground.layer.cornerRadius = 15
        
        let activityIndicatorView: UIActivityIndicatorView = UIActivityIndicatorView()
        activityIndicatorView.frame = CGRect(x:0.0, y:0.0, width: 40.0, height: 40.0)
        activityIndicatorView.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.whiteLarge
        activityIndicatorView.center = CGPoint(x:viewBackground.frame.size.width/2, y:viewBackground.frame.size.height/2)
        
        if startAnimate! {
            viewBackground.addSubview(activityIndicatorView)
            mainContainter.addSubview(viewBackground)
            self.view.addSubview(mainContainter)
            activityIndicatorView.startAnimating()
        } else {
            for subview in self.view.subviews {
                if subview.tag == 789456123 {
                    subview.removeFromSuperview()
                }
            }
        }
        
        // return activityIndicatorView
        
    }
    
    
}

