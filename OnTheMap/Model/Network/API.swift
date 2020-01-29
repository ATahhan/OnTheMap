//
//  API.swift
//  PinSample
//
//  Created by Ammar AlTahhan on 15/11/2018.
//  Copyright © 2018 Udacity. All rights reserved.
//

import Foundation

class API {
    
    private static var userInfo = UserInfo()
    private static var sessionId: String?
    
    static func postSession(username: String, password: String, completion: @escaping (String?)->Void) {
        guard let url = URL(string: APIConstants.SESSION) else {
            completion("Supplied url is invalid")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = HTTPMethod.post.rawValue
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = "{\"udacity\": {\"username\": \"\(username)\", \"password\": \"\(password)\"}}".data(using: .utf8)
        let session = URLSession.shared
        let task = session.dataTask(with: request) { data, response, error in
            var errString: String?
            if let statusCode = (response as? HTTPURLResponse)?.statusCode { //Request sent succesfully
                if statusCode < 400 { //Response is ok
                    
                    let newData = data?.subdata(in: 5..<data!.count)
                    if let json = try? JSONSerialization.jsonObject(with: newData!, options: []),
                        let dict = json as? [String:Any],
                        let sessionDict = dict["session"] as? [String: Any],
                        let accountDict = dict["account"] as? [String: Any]  {
                        
                        self.sessionId = sessionDict["id"] as? String
                        self.userInfo.key = accountDict["key"] as? String
                        
                        getPublicUserName(completion: { (err) in
                            
                        })
                    } else { //Err in parsing data
                        errString = "Couldn't parse response"
                    }
                } else { //Err in given login credintials
                    errString = "Provided login credintials didn't match our records"
                }
            } else { //Request failed to sent
                errString = "Check your internet connection"
            }
            DispatchQueue.main.async {
                completion(errString)
            }
            
        }
        task.resume()
    }
    
    static func deleteSession(completion: @escaping (String?)->Void) {
        guard let url = URL(string: APIConstants.SESSION) else {
            completion("Supplied url is invalid")
            return
        }
        var request = URLRequest(url: url)
        var xsrfCookie: HTTPCookie? = nil
        let sharedCookieStorage = HTTPCookieStorage.shared
        for cookie in sharedCookieStorage.cookies! {
            if cookie.name == "XSRF-TOKEN" { xsrfCookie = cookie }
        }
        if let xsrfCookie = xsrfCookie {
            request.setValue(xsrfCookie.value, forHTTPHeaderField: "X-XSRF-TOKEN")
        }
        let session = URLSession.shared
        let task = session.dataTask(with: request) { data, response, error in
            if error != nil { // Handle error…
                return
            }
            if (data?.count ?? 0) > 5, let newData = data?.subdata(in: 5..<data!.count) { /* subset response data! */
                print(String(data: newData, encoding: .utf8)!)
            }
            DispatchQueue.main.async {
                completion(nil)
            }
        }
        task.resume()
    }
    
    static func getPublicUserName(completion: @escaping (_ error: Error?)->Void) {
        guard let userId = userInfo.key, let url = URL(string: "\(APIConstants.PUBLIC_USER)\(userId)") else {
            completion(NSError(domain: "URLError", code: 0, userInfo: nil))
            return
        }
        
        var request = URLRequest(url: url)
        request.addValue(self.sessionId!, forHTTPHeaderField: "session_id")
        let session = URLSession.shared
        let task = session.dataTask(with: request) { data, response, error in
            var firstName: String?, lastName: String?, nickname: String = ""
            if let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode < 400 { //Request sent succesfully
                let newData = data?.subdata(in: 5..<data!.count)
                if let json = try? JSONSerialization.jsonObject(with: newData!, options: []),
                    let dict = json as? [String:Any] {
                    
                    nickname = dict["nickname"] as? String ?? ""
                    firstName = dict["first_name"] as? String ?? nickname
                    lastName = dict["last_name"] as? String ?? nickname
                    
                    userInfo.firstName = firstName
                    userInfo.lastName = lastName
                }
            }
            
            DispatchQueue.main.async {
                completion(nil)
            }
            
        }
        task.resume()
        
    }
    
    class Parser {
        
        static func getStudentLocations(limit: Int = 100, skip: Int = 0, orderBy: SLParam = .updatedAt, completion: @escaping (LocationsData?)->Void) {
            guard let url = URL(string: "\(APIConstants.STUDENT_LOCATION)?\(APIConstants.ParameterKeys.LIMIT)=\(limit)&\(APIConstants.ParameterKeys.SKIP)=\(skip)&\(APIConstants.ParameterKeys.ORDER)=-\(orderBy.rawValue)") else {
                completion(nil)
                return
            }
            
            var request = URLRequest(url: url)
            request.httpMethod = HTTPMethod.get.rawValue
            request.addValue(APIConstants.HeaderValues.PARSE_APP_ID, forHTTPHeaderField: APIConstants.HeaderKeys.PARSE_APP_ID)
            request.addValue(APIConstants.HeaderValues.PARSE_API_KEY, forHTTPHeaderField: APIConstants.HeaderKeys.PARSE_API_KEY)
            let session = URLSession.shared
            let task = session.dataTask(with: request) { data, response, error in
                var studentLocations: [StudentLocation] = []
                if let statusCode = (response as? HTTPURLResponse)?.statusCode { //Request sent succesfully
                    if statusCode < 400 { //Response is ok
                        
                        do {
                            let data = try JSONDecoder().decode(LocationsData.self, from: data!)
                        } catch {
                            print(error)
                        }
                        if let json = try? JSONSerialization.jsonObject(with: data!, options: []),
                            let dict = json as? [String:Any],
                            let results = dict["results"] as? [Any] {
                            
                            for location in results {
                                let data = try! JSONSerialization.data(withJSONObject: location)
                                let studentLocation = try! JSONDecoder().decode(StudentLocation.self, from: data)
                                studentLocations.append(studentLocation)
                            }
                            
                        }
                    }
                }
                
                DispatchQueue.main.async {
                    completion(LocationsData(results: studentLocations))
                }
                
            }
            task.resume()
        }
        
        static func postLocation(_ location: StudentLocation, completion: @escaping (String?)->Void) {
            guard let accountId = userInfo.key, let url = URL(string: "\(APIConstants.STUDENT_LOCATION)") else {
                completion("Invilid url")
                return
            }
            
            var request = URLRequest(url: url)
            request.httpMethod = HTTPMethod.post.rawValue
            request.addValue(APIConstants.HeaderValues.PARSE_APP_ID, forHTTPHeaderField: APIConstants.HeaderKeys.PARSE_APP_ID)
            request.addValue(APIConstants.HeaderValues.PARSE_API_KEY, forHTTPHeaderField: APIConstants.HeaderKeys.PARSE_API_KEY)
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpBody = "{\"uniqueKey\": \"\(accountId)\", \"firstName\": \"\("John")\", \"lastName\": \"\("Doe")\",\"mapString\": \"\(location.mapString!)\", \"mediaURL\": \"\(location.mediaURL!)\",\"latitude\": \(location.latitude!), \"longitude\": \(location.longitude!)}".data(using: .utf8)
            let session = URLSession.shared
            let task = session.dataTask(with: request) { data, response, error in
                var errString: String?
                if let statusCode = (response as? HTTPURLResponse)?.statusCode { //Request sent succesfully
                    if statusCode >= 400 { //Response is ok
                        errString = "Couldn't post your location"
                    }
                } else { //Request failed to sent
                    errString = "Check your internet connection"
                }
                DispatchQueue.main.async {
                    completion(errString)
                }
            }
            task.resume()
            
            
        }
        
        static func postLocation(firstName: String, lastName: String, location: String, media: String, lat: Double, long: Double, completion: @escaping (String?)->Void) {
            
            var request = URLRequest(url: URL(string: "https://parse.udacity.com/parse/classes/StudentLocation")!)
            request.httpMethod = "POST"
            request.addValue("application/json", forHTTPHeaderField: "Accept")
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpBody = "{\"uniqueKey\": \"\(1111)\", \"firstName\": \"\(firstName)\", \"lastName\": \"\(lastName)\",\"mapString\": \"\(location)\", \"mediaURL\": \"\(media)\",\"latitude\": \"\(lat)\", \"longitude\": \"\(long)\"}".data(using: .utf8)
                
                let session = URLSession.shared
                
                let task = session.dataTask(with: request) { data, response, error in
                    var err: String?
                    if let status = (response as? HTTPURLResponse)?.statusCode {
                        if status >= 200 && status < 300 {
                            print ("Data was added successfully")
                        }
                        else {
                            err = "Couldn’t parse response"
                        }
                        
                    } else {
                        err = "Check your internet connection"
                    }
                    DispatchQueue.main.async {
                        completion(err)
                    }
                    
                }
                task.resume()
                
                
            }
    }
    
}
