//
//  ServiceHelper.swift
//  MIT
//
//  Created by Thirumal on 23/02/17.
//  Copyright © 2017 Benz. All rights reserved.
//
import UIKit

class WebServiceDataModel: NSObject
{
    var error : Error?
    var returnValue : Any?
    var response : URLResponse?
}

class ServiceHelper: NSObject
{
    static let sharedInstance = ServiceHelper()
    
    func webServiceCall(urlRequest : URLRequest , completionHandler : @escaping (WebServiceDataModel) -> Void)
    {
        if checkInternetConnection()
        {
            //create the session object
            let session = URLSession.shared
            //create dataTask using the session object to send data to the server
            let task = session.dataTask(with: urlRequest , completionHandler: { data, response, error in
            
                let webServiceData = WebServiceDataModel()
                webServiceData.response = response
                if data != nil
                {
                    do
                    {
                        if let json = try JSONSerialization.jsonObject(with: data!, options: .allowFragments) as? [String: Any]
                        {
                            webServiceData.returnValue = json
                        }
                        else
                        {
                            webServiceData.error = self.getLocalErrorWithCode(errorCode: 102, errorMessage: "Json error, Please try again later.")
                        }
                    }
                    catch
                    {
                        webServiceData.error = self.getLocalErrorWithCode(errorCode: 101, errorMessage: "Invalid Data, Please try again later.")
                    }
                }
                else
                {
                    if error != nil
                    {
                        webServiceData.error = error
                    }
                    else
                    {
                        webServiceData.error = self.getLocalErrorWithCode(errorCode: 101, errorMessage: "Unable to connect to server, Please try again.")
                    }
                    DispatchQueue.main.async(){
                        completionHandler(webServiceData)
                    }
                }
            })
            task.resume()
        }
        else
        {
            let serviceError = WebServiceDataModel()
            serviceError.error = self.getLocalErrorWithCode(errorCode: 100, errorMessage: "No Internet connection, Please try again later.")
            completionHandler(serviceError)
        }
    }
    
    func getLocalErrorWithCode(errorCode : Int, errorMessage : String) -> NSError
    {
       return NSError(domain: Constants.ServiceApi.ErrorDomain, code: errorCode, userInfo: [NSLocalizedDescriptionKey : errorMessage])
    }
    
    func checkInternetConnection() -> Bool
    {
        if let reachabilityStatus = Reachability()?.isReachable
        {
            return reachabilityStatus
        }
        return false
    }
}
