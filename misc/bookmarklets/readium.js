// skip to noscript or whatever versions of pages
// source: https://sugoidesune.github.io/readium/
javascript:var%20currentsite%3Ddocument.querySelector(%22meta%5Bproperty%3D'al%3Aandroid%3Aapp_name'%5D%22)%3Fdocument.querySelector(%22meta%5Bproperty%3D'al%3Aandroid%3Aapp_name'%5D%22).content%3Awindow.location.href%3Bfunction%20isPage(b)%7Bconsole.log(b%2B%22%20%22%2Bcurrentsite.includes(b))%3Breturn%20currentsite.includes(b)%7Dfunction%20process(b)%7Bvar%20a%3Db%3BisPage(%22NYTimes%22)%26%26(document.querySelector(%22html%22).innerHTML%3Da)%3BisPage(%22Medium%22)%26%26(a%3Db.replace(%2F%3C%5C%2F%3Fnoscript%3E%2Fg%2C%22%22)%2Cdocument.querySelector(%22html%22).innerHTML%3Da)%3Bif(isPage(%22Bloomberg%22)%7C%7CisPage(%22businessinsider%22))a%3Ddocument.createElement(%22html%22)%2Ca.innerHTML%3Db%2Ca.querySelectorAll(%22script%22).forEach(function(a)%7Breturn%20a.outerHTML%3D%22%22%7D)%2Ca%3Da.outerHTML%2Cdocument.open()%2Cdocument.write(a)%2Cdocument.close()%3BisPage(%22businessinsider%22)%26%26(a%3Ddocument.createElement(%22html%22)%2Ca.innerHTML%3Db%2Ca.querySelectorAll(%22script%22).forEach(function(a)%7Breturn%20a.outerHTML%3D%22%22%7D)%2Ca.querySelectorAll(%22figure%22).forEach(function(a)%7Ba.innerHTML%3Da.querySelector(%22noscript%22).innerHTML%7D)%2Ca%3Da.outerHTML%2Cdocument.open()%2Cdocument.write(a)%2Cdocument.close())%7Dfetch(window.location.href%2C%7Bcredentials%3A%22omit%22%2Credirect%3A%22follow%22%2Cmode%3A%22no-cors%22%7D).then(function(b)%7Breturn%20b.text()%7D).then(function(b)%7Bprocess(b)%7D)%3Bvoid+0
