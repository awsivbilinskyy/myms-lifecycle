node("cd") {
    git url: "https://github.com/awsivbilinskyy/my/${serviceName}.git"
    dockerFlow(serviceName, ["scale", "proxy"], ["--scale=\"" + scale + "\""])
}