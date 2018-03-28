const ngGetStuff = (moduleName) => angular.module(moduleName)._invokeQueue.map(a => `${a[1]}: ${a[2][0]}`)

// usage: copy(ngGetStuff('sellerApp'))
