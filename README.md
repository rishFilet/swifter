# swifter
This is an updated version of using swifter for UItesting on iOS with graphql queries

There are two files in this repo.

1) MockSwifterServer.swift is used to set up the server and contain all the queries made to api endpoints nad graphql

2) LoginTests.swift is an example file for how to implement the mock server and running a test. Only setup and teardown need to be done
before the main function of each test. If an alternate response is needed, then call that response in the test using:
dynamicStubs.setupStub(url: , filename: , method: )

Swifter is originally located in this repo: https://github.com/httpswift/swifter 
