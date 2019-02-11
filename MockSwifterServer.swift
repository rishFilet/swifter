//
//  MockSwifterServer.swift
//  ecobeeUITests
//
//  Created by Rishi Khan on 2019-01-03.
//  Copyright © 2019 ecobee. All rights reserved.
//

import Foundation
import Swifter

enum HTTPMethod {
    case POST
    case GET
    case PUT
}

struct HTTPStubInfo {
    let url: String
    let jsonFilename: String
    let method: HTTPMethod
}

let initialStubs = [
    HTTPStubInfo(url: "/1/user", jsonFilename: "user", method: .GET),
    HTTPStubInfo(url: "/authorize", jsonFilename: "authorize", method: .POST),
    HTTPStubInfo(url: "/token", jsonFilename: "token", method: .POST),
    HTTPStubInfo(url: "/1/thermostat", jsonFilename: "tstat", method: .GET),
    HTTPStubInfo(url: "/1/thermostatSummary", jsonFilename: "tstatSum", method: .GET),
    HTTPStubInfo(url: "/1/group", jsonFilename: "group", method: .GET),
    HTTPStubInfo(url: "/ea/devices", jsonFilename: "eaDevices", method: .GET),
    HTTPStubInfo(url: "/ea/devices/ls", jsonFilename: "eaDevicesLs", method: .GET),
    HTTPStubInfo(url: "/graphql", jsonFilename: "", method: .POST)
]
struct graphQuery {
    let queryName: String
    let jsonResponseFile: String
}

let graphDict = [
    graphQuery(queryName: "RootModelHomeSettings",jsonResponseFile: "RootModelHomeSettings"),
    graphQuery(queryName: "Vacations",jsonResponseFile:"vacations"),
    graphQuery(queryName:"HomeDevices",jsonResponseFile:"HomeDevices")
]


class MockServer {
    
    var server = HttpServer()
    
    func setUp() {
        try! server.start(port)
        setupInitialStubs()
    }
    
    func tearDown() {
        server.stop()
    }
    
    func setupInitialStubs() {
        for stub in initialStubs {
            setupStub(url: stub.url, filename: stub.jsonFilename, method: stub.method)
        }
    }
    
    public func setupStub(url: String, filename: String, method: HTTPMethod) {
        var jfilename: String?

            let response: ((HttpRequest) -> HttpResponse) = { request in
                if !(request.body.isEmpty) && request.queryParams.isEmpty{
                    let req_body = String(bytes: request.body, encoding: .utf8)
                    for query in graphDict{
                        if (req_body?.contains(query.queryName))!{
                            jfilename = query.jsonResponseFile
                            break
                        }
                    }
                }
                else {
                    jfilename = filename
                }
                let testBundle = Bundle(for: type(of: self))
                let filePath = testBundle.path(forResource: jfilename, ofType: "json")
                let fileUrl = URL(fileURLWithPath: filePath!)
                let data = try! Data(contentsOf: fileUrl, options: .uncached)
                let json = self.dataToJSON(data: data)
                return HttpResponse.ok(.json(json as AnyObject))
            }
            switch method {
            case .GET :
                server.GET[url] = response
            case .POST:
                server.POST[url] = response
            case .PUT:
                server.PUT[url] = response
            }
        }
    
    
    func dataToJSON(data: Data) -> Any? {
        do {
            return try JSONSerialization.jsonObject(with: data, options: .mutableContainers)
        } catch let myJSONError {
            print(myJSONError)
        }
        return nil
    }

    // MARK: Private

    let port: UInt16 = 2300
    
}
//

