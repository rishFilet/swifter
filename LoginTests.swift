//
//  LoginTest.swift
//  ecobeeUITests
//
//  Created by Henry Lo on 2018-10-22.
//  Edited by Rishi Khan on 2019-01-20
//  Copyright © 2018 ecobee. All rights reserved.
//

import XCTest

class LoginTests: BaseTest {
    
        //Creates a tiny http server on the device
        let mock = MockServer()
        //Starts up the server on the localhost:2300
        override func setUp() {
            super.setUp()
            mock.setUp()
        }
    
        //Shuts down the local server after the test is complete
        override func tearDown() {
            mock.tearDown()
            super.tearDown()
        }
    
    func testLoginLogOut() {
        if DashboardPage().isNavigationVisible {
            DashboardPage().navigateToAccount().logout()
        }        
        //If you want to test a certain response other than what is expected,
        //use this line of code and replace filename with the json file with the desired response
        //dynamicStubs.setupStub(url: "/ea/devices", filename: "group", method: .GET)
        LoginPage().login(EnvironmentVariables.ecobeeUsername, EnvironmentVariables.ecobeePassword)

        

        let dashboardPage = DashboardPage()

        dashboardPage.waitForPageLoad()

        dashboardPage.cancelMangeHomesTooltipIfExists()

        XCTAssertEqual("ecobee.HomeTabView", dashboardPage.getPageTitle)
        dashboardPage.navigateToAccount().logout()
    }
    
}

