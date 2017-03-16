//
//  InAppPurchasesViewController.swift
//  DOQS Q
//
//  Created by Jonathan on 21/10/15.
//  Copyright © 2015 Jonathan Fiorentini. All rights reserved.
//

import Foundation
import UIKit
import StoreKit

class InAppPurchasesViewController: UIAlertController,SKProductsRequestDelegate,SKPaymentTransactionObserver{
    
    var products:[SKProduct]
    var productsRequest:SKProductsRequest
    var cancelButton:UIButton
    var restorePurchasesButton:UIButton
    var alert:UIAlertController
    
    func getAlert()->UIAlertController{
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .currency
        numberFormatter.locale = Locale.current
        let price = numberFormatter.string(from: products[0].price)
        self.alert.message = "Get the full version for \(price!) and access all levels"
        self.alert = UIAlertController(title: "Unlock Full Version", message: "Get the full version for \(price!) and access all levels", preferredStyle:UIAlertControllerStyle.alert)
        let buyHandler = {(alert:UIAlertAction)->() in
            self.buyProduct()
        }
        let restoreHandler = {(alert:UIAlertAction)->() in
            self.restorePurchases()
        }
        let buy = UIAlertAction(title: "Buy Full Version", style: UIAlertActionStyle.default, handler:buyHandler)
        let cancel = UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: UIAlertActionStyle.default, handler: nil)
        let restore = UIAlertAction(title: NSLocalizedString("Restore Purchase", comment: ""), style: UIAlertActionStyle.default, handler: restoreHandler)
        alert.addAction(buy)
        alert.addAction(cancel)
        alert.addAction(restore)
        return alert
    }
    
    
    init(){
        self.products = [SKProduct]()
        self.productsRequest = SKProductsRequest()
        self.cancelButton = UIButton()
        self.restorePurchasesButton = UIButton()
        self.alert = UIAlertController()
        super.init(nibName: nil, bundle: nil)
        self.title = "Unlock Full Version"
        SKPaymentQueue.default().add(self)
        self.setupAlert()
    }
    
    func setupAlert(){
        
        let buyHandler = {(alert:UIAlertAction)->() in
            self.buyProduct()
        }
        
        let restoreHandler = {(alert:UIAlertAction)->() in
            self.restorePurchases()
        }
        let buy = UIAlertAction(title: "Buy Full Version", style: UIAlertActionStyle.default, handler:buyHandler)
        let cancel = UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: UIAlertActionStyle.default, handler: nil)
        let restore = UIAlertAction(title: NSLocalizedString("Restore Purchase", comment: ""), style: UIAlertActionStyle.default, handler: restoreHandler)
        self.addAction(buy)
        self.addAction(cancel)
        self.addAction(restore)
    }
    
    
    func buyProduct(){
        print("testpayment")
        let payment = SKPayment(product: self.products[0])
        print("testpayment")
        SKPaymentQueue.default().add(payment)
        print("testpayment")
    }
    
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction in transactions {
            switch transaction.transactionState
            {
            case SKPaymentTransactionState.purchased:
                print("Transaction Approved")
                print("Product Identifier: \(transaction.payment.productIdentifier)")
                self.deliverProduct(transaction)
                SKPaymentQueue.default().finishTransaction(transaction)
            case SKPaymentTransactionState.failed:
                print("Transaction Failed")
                SKPaymentQueue.default().finishTransaction(transaction)
            case SKPaymentTransactionState.restored:
                print("Transaction Restored")
                print("Product Identifier: \(transaction.payment.productIdentifier)")
                self.deliverProduct(transaction)
            default:
                break
            }
        }
    }
    
    
    func restorePurchases() {
        SKPaymentQueue.default().add(self)
        SKPaymentQueue.default().restoreCompletedTransactions()
    }
    
    func paymentQueueRestoreCompletedTransactionsFinished(_ queue: SKPaymentQueue) {
        print("Transactions Restored")
        for transaction:SKPaymentTransaction in queue.transactions {
            deliverProduct(transaction)
        }
        let restorationConfirmation = UIAlertController(title: NSLocalizedString("RestorationConfirmationTitle", comment: ""), message: NSLocalizedString("RestorationConfirmationMessage", comment: ""), preferredStyle: UIAlertControllerStyle.alert)
        let okay = UIAlertAction(title: NSLocalizedString("Okay", comment: ""), style: UIAlertActionStyle.cancel, handler: nil)
        restorationConfirmation.addAction(okay)
        self.present(restorationConfirmation, animated: true, completion: nil)
    }
    func deliverProduct(_ transaction:SKPaymentTransaction) {
        var purchasedProductsArray = [String]()
        if let pruchasedProducts = UserDefaults.standard.array(forKey: Game.PurchasedProducts) as? [String]{
            purchasedProductsArray.append(contentsOf: pruchasedProducts)
        }
        purchasedProductsArray.append(transaction.payment.productIdentifier)
        let newPurchasedProducts = purchasedProductsArray
        UserDefaults.standard.set(newPurchasedProducts, forKey: Game.PurchasedProducts)
        Game.updateInAppPurchasesAuthorizations()
    }
    
    func validateProductIdentifiers(){
        if SKPaymentQueue.canMakePayments() {
            self.productsRequest = SKProductsRequest(productIdentifiers: Set(Game.ProductIdentifiers))
            self.productsRequest.delegate = self
            self.productsRequest.start()
        }
        else {
            print("Cannot Make Payment")
        }
    }
    
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        print("requesting producs")
        self.products = response.products
        for product in response.products {
            print(product.productIdentifier)
            print(product.localizedTitle)
            print(product.localizedDescription)
            print(product.price)
        }
        print("finished producs")
        
        let notif = Notification(name: Notification.Name(rawValue: "test"), object: nil)
        NotificationCenter.default.post(notif)
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .currency
        numberFormatter.locale = Locale.current
        let price = numberFormatter.string(from: products[0].price)
        
        self.alert.message = "Get the full version for \(price!) and access all levels"
        
        for invalidIdentifier in response.invalidProductIdentifiers {
            print(invalidIdentifier)
        }
        print("finished producs")
        
    }
    
    
    
    deinit{
        self.productsRequest.cancel()
        SKPaymentQueue.default().remove(self)
        print("deinitofficla")
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func cancel(){
        DispatchQueue.main.async(execute: {
            self.dismiss(animated: true, completion: nil)
        })
    }
    
}
