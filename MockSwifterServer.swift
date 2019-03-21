//
//  MockSwifterServer.swift
//  ecobeeUITests
//
//  Created by Rishi Khan on 2019-01-03.
//

import Foundation
import Swifter

enum HTTPMethod {
    case POST
    case GET
    case PUT
}

// MARK: - HTTPStubInfo

struct HTTPStubInfo {
    let url: String
    let jsonFilename: String
    let method: HTTPMethod
}

//Place the correct responses here for normal api calls
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

// MARK: - _Name

struct GraphQuery {
    let name: String
    let jsonResponseFile: String
}

//Place the responses here for the graphql calls. The query name should be anything unique in the
// graph's query variable. In these examples i used the substring right after the word 'query'
let graphDict = [
    GraphQuery(name: "RootModelHomeSettings", jsonResponseFile: "RootModelHomeSettings"),
    GraphQuery(name: "Vacations", jsonResponseFile: "vacations"),
    GraphQuery(name: "HomeDevices", jsonResponseFile: "HomeDevices")
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
        let response: ((HttpRequest) -> HttpResponse) = { request in
            var jfilename: String?
            if !(request.body.isEmpty) && request.queryParams.isEmpty {
                let req_body = String(bytes: request.body, encoding: .utf8)
                jfilename = graphDict.first(where: { req_body?.contains($0.name) ?? false })?.jsonResponseFile
            } else {
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
