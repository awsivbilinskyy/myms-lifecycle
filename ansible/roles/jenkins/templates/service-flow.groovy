node("cd") {
    git url: "https://github.com/awsivbilinskyy/my${serviceName}.git"
    def flow = load "/data/scripts/workflow-util.groovy"
    def prodIp = "10.100.198.201"
    flow.provision("prod2.yml")
    flow.buildTests(serviceName, registryIpPort)
    flow.runTests(serviceName, "tests", "")
    flow.buildService(serviceName, registryIpPort)
    flow.deploy(serviceName, prodIp)
    flow.updateProxy(serviceName, prodIp, "prod")
}
