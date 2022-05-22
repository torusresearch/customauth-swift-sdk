
import Foundation

fileprivate func mustDecodeJSON(_ s: String) -> [String: Any] {
    return try! JSONSerialization.jsonObject(with: Data(s.utf8), options: []) as! [String: Any]
}

fileprivate func httpBodyStreamToData(stream: InputStream?) -> Data? {
    guard let bodyStream = stream else { return nil }
    bodyStream.open()

    // Will read 16 chars per iteration. Can use bigger buffer if needed
    let bufferSize: Int = 16

    let buffer = UnsafeMutablePointer<UInt8>.allocate(capacity: bufferSize)

    var dat = Data()

    while bodyStream.hasBytesAvailable {
        let readDat = bodyStream.read(buffer, maxLength: bufferSize)
        dat.append(buffer, count: readDat)
    }

    buffer.deallocate()

    bodyStream.close()

    return dat
}

fileprivate func stubMatcher(host: String, scheme: String, path: String, method: String, requestHeaders: [String: String]) -> (URLRequest) -> Bool {
    return { (req: URLRequest) -> Bool in
        if req.url?.host != host || req.url?.scheme != scheme || req.url?.path != path || req.httpMethod != method {
            return false
        }
        for (name, value) in requestHeaders {
            if req.value(forHTTPHeaderField: name) != value {
                return false
            }
        }
        return true
    }
}

fileprivate func stubMatcherWithBody(host: String, scheme: String, path: String, method: String, requestHeaders: [String: String], body: [String: Any]) -> (URLRequest) -> Bool {
    return { (req: URLRequest) -> Bool in
        if !stubMatcher(host: host, scheme: scheme, path: path, method: method, requestHeaders: requestHeaders)(req) {
            return false
        }
        guard
            let bodyData = StubURLProtocol.property(forKey: httpBodyKey, in: req) as? Data,
            let jsonBody = (try? JSONSerialization.jsonObject(with: bodyData, options: [])) as? [String: Any]
        else {
            return false
        }
        return NSDictionary(dictionary: jsonBody).isEqual(to: body)
    }
}

fileprivate let injectedURLs: Set = [
    URL(string: "https://www.googleapis.com/userinfo/v2/me"),
    URL(string: "https://ropsten.infura.io/v3/7f287687b3d049e2bea7b64869ee30a3"),
    URL(string: "https://teal-15-4.torusnode.com/jrpc"),
    URL(string: "https://teal-15-2.torusnode.com/jrpc"),
    URL(string: "https://teal-15-1.torusnode.com/jrpc"),
    URL(string: "https://teal-15-3.torusnode.com/jrpc"),
    URL(string: "https://teal-15-5.torusnode.com/jrpc"),
    URL(string: "https://signer.tor.us/api/allow"),
    URL(string: "https://metadata.tor.us/get"),
]

fileprivate let injectedStubs: [Stub] = [
    Stub(
        requestMatcher: stubMatcher(
            host: "www.googleapis.com",
            scheme: "https",
            path: "/userinfo/v2/me",
            method: "GET",
            requestHeaders: mustDecodeJSON(#"{"Content-Type":"application/json","Authorization":"Bearer ya29.a0ARrdaM96u3PfVhg9xbkCPuecmF6YaylxRcJwKJTlHY8kwwuSyKbqme2qBbTdLoVORMZy4n8Al5Wr1HCnfjCesU38W1xkSgFNoPhRgTen6Zqxyr_tOddJw6-TUUbe45z6Zvkbx8DzBHShQkm-KbbNzh_M00kh","Accept":"application/json"}"#) as! [String: String]
        ),
        responseBody: Data(#"{"id":"109111953856031799639","email":"michael@tor.us","verified_email":true,"name":"Michael Lee","given_name":"Michael","family_name":"Lee","picture":"https://lh3.googleusercontent.com/a/AATXAJwsBb98gSYjVNlBBAhXJjvqNOw2GDSeTf0I6SJh=s96-c","locale":"en","hd":"tor.us"}"#.utf8),
        statusCode: 200,
        responseHeaders: mustDecodeJSON(#"{"Date":"Sun, 17 Oct 2021 10:57:29 GMT","x-frame-options":"SAMEORIGIN","Pragma":"no-cache","x-xss-protection":"0","Content-Encoding":"gzip","Server":"ESF","Cache-Control":"no-cache, no-store, max-age=0, must-revalidate","Vary":"Origin, X-Origin, Referer","Alt-Svc":"h3=\":443\"; ma=2592000,h3-29=\":443\"; ma=2592000,h3-T051=\":443\"; ma=2592000,h3-Q050=\":443\"; ma=2592000,h3-Q046=\":443\"; ma=2592000,h3-Q043=\":443\"; ma=2592000,quic=\":443\"; ma=2592000; v=\"46,43\"","x-content-type-options":"nosniff","Content-Length":"234","Content-Type":"application/json; charset=UTF-8","Expires":"Mon, 01 Jan 1990 00:00:00 GMT"}"#) as! [String: String]
    ),

    Stub(
        requestMatcher: stubMatcherWithBody(
            host: "ropsten.infura.io",
            scheme: "https",
            path: "/v3/b8cdb0e4cff24599a286bf8e87ff1c96",
            method: "POST",
            requestHeaders: mustDecodeJSON(#"{"Content-Type":"application/json","Accept":"application/json"}"#) as! [String: String],
            body: mustDecodeJSON(#"{"jsonrpc":"2.0","method":"eth_call","id":1,"params":[{"to":"0x4023d2a0d330bf11426b12c6144cfb96b7fa6183","data":"0x76671808"},"latest"]}"#)
        ),
        responseBody: Data(#"{"jsonrpc":"2.0","id":1,"result":"0x000000000000000000000000000000000000000000000000000000000000000f"}"#.utf8),
        statusCode: 200,
        responseHeaders: mustDecodeJSON(#"{"Vary":"Accept-Encoding, Origin","Date":"Sun, 17 Oct 2021 10:57:30 GMT","Content-Length":"102","Content-Type":"application/json"}"#) as! [String: String]
    ),

    Stub(
        requestMatcher: stubMatcherWithBody(
            host: "ropsten.infura.io",
            scheme: "https",
            path: "/v3/b8cdb0e4cff24599a286bf8e87ff1c96",
            method: "POST",
            requestHeaders: mustDecodeJSON(#"{"Content-Type":"application/json","Accept":"application/json"}"#) as! [String: String],
            body: mustDecodeJSON(#"{"jsonrpc":"2.0","method":"eth_call","id":1,"params":[{"to":"0x4023d2a0d330bf11426b12c6144cfb96b7fa6183","data":"0x135022c2000000000000000000000000000000000000000000000000000000000000000f"},"latest"]}"#)
        ),
        responseBody: Data(#"{"jsonrpc":"2.0","id":1,"result":"0x000000000000000000000000000000000000000000000000000000000000000f00000000000000000000000000000000000000000000000000000000000000050000000000000000000000000000000000000000000000000000000000000003000000000000000000000000000000000000000000000000000000000000000100000000000000000000000000000000000000000000000000000000000000e0000000000000000000000000000000000000000000000000000000000000000e00000000000000000000000000000000000000000000000000000000000000100000000000000000000000000000000000000000000000000000000000000005000000000000000000000000455d2ba3f20fa83b9f824e665dd201d908c79dce000000000000000000000000b452bbd6f4d52d87f33336aad921538bf8dfdf67000000000000000000000000e3c0493536f20d090c8f9427d8fdfe548af3266200000000000000000000000054ac312ed9ba51cdd65f182487f29a3999dbf4e200000000000000000000000057f7a525608dc540fefc3e851700a4189d19142d"}"#.utf8),
        statusCode: 200,
        responseHeaders: mustDecodeJSON(#"{"Content-Length":"870","Vary":"Accept-Encoding, Origin","Content-Type":"application/json","Date":"Sun, 17 Oct 2021 10:57:31 GMT"}"#) as! [String: String]
    ),

    Stub(
        requestMatcher: stubMatcherWithBody(
            host: "ropsten.infura.io",
            scheme: "https",
            path: "/v3/b8cdb0e4cff24599a286bf8e87ff1c96",
            method: "POST",
            requestHeaders: mustDecodeJSON(#"{"Accept":"application/json","Content-Type":"application/json"}"#) as! [String: String],
            body: mustDecodeJSON(#"{"jsonrpc":"2.0","method":"eth_call","id":1,"params":[{"to":"0x4023d2a0d330bf11426b12c6144cfb96b7fa6183","data":"0xbafb358100000000000000000000000054ac312ed9ba51cdd65f182487f29a3999dbf4e2"},"latest"]}"#)
        ),
        responseBody: Data(#"{"jsonrpc":"2.0","id":1,"result":"0x00000000000000000000000000000000000000000000000000000000000000c0000000000000000000000000000000000000000000000000000000000000000425a98d9ae006aed1d77e81d58be8f67193d13d01a9888e2923841894f4b0bf9cf63d40df480dacf68922004ed36dbab9e2969181b047730a5ce0797fb695824900000000000000000000000000000000000000000000000000000000000001000000000000000000000000000000000000000000000000000000000000000120000000000000000000000000000000000000000000000000000000000000001b7465616c2d31352d352e746f7275736e6f64652e636f6d3a343433000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000"}"#.utf8),
        statusCode: 200,
        responseHeaders: mustDecodeJSON(#"{"Date":"Sun, 17 Oct 2021 10:57:31 GMT","Content-Type":"application/json","Content-Length":"678","Vary":"Accept-Encoding, Origin"}"#) as! [String: String]
    ),

    Stub(
        requestMatcher: stubMatcherWithBody(
            host: "ropsten.infura.io",
            scheme: "https",
            path: "/v3/b8cdb0e4cff24599a286bf8e87ff1c96",
            method: "POST",
            requestHeaders: mustDecodeJSON(#"{"Accept":"application/json","Content-Type":"application/json"}"#) as! [String: String],
            body: mustDecodeJSON(#"{"jsonrpc":"2.0","method":"eth_call","id":1,"params":[{"to":"0x4023d2a0d330bf11426b12c6144cfb96b7fa6183","data":"0xbafb3581000000000000000000000000455d2ba3f20fa83b9f824e665dd201d908c79dce"},"latest"]}"#)
        ),
        responseBody: Data(#"{"jsonrpc":"2.0","id":1,"result":"0x00000000000000000000000000000000000000000000000000000000000000c000000000000000000000000000000000000000000000000000000000000000011363aad8868cacd7f8946c590325cd463106fb3731f08811ab4302d2deae35c3d77eebe5cdf466b475ec892d5b4cffbe0c1670525debbd97eee6dae2f87a7cbe00000000000000000000000000000000000000000000000000000000000001000000000000000000000000000000000000000000000000000000000000000120000000000000000000000000000000000000000000000000000000000000001b7465616c2d31352d312e746f7275736e6f64652e636f6d3a343433000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000"}"#.utf8),
        statusCode: 200,
        responseHeaders: mustDecodeJSON(#"{"Vary":"Accept-Encoding, Origin","Date":"Sun, 17 Oct 2021 10:57:31 GMT","Content-Length":"678","Content-Type":"application/json"}"#) as! [String: String]
    ),

    Stub(
        requestMatcher: stubMatcherWithBody(
            host: "ropsten.infura.io",
            scheme: "https",
            path: "/v3/b8cdb0e4cff24599a286bf8e87ff1c96",
            method: "POST",
            requestHeaders: mustDecodeJSON(#"{"Content-Type":"application/json","Accept":"application/json"}"#) as! [String: String],
            body: mustDecodeJSON(#"{"jsonrpc":"2.0","method":"eth_call","id":1,"params":[{"to":"0x4023d2a0d330bf11426b12c6144cfb96b7fa6183","data":"0xbafb3581000000000000000000000000b452bbd6f4d52d87f33336aad921538bf8dfdf67"},"latest"]}"#)
        ),
        responseBody: Data(#"{"jsonrpc":"2.0","id":1,"result":"0x00000000000000000000000000000000000000000000000000000000000000c000000000000000000000000000000000000000000000000000000000000000027c8cc521c48690f016bea593f67f88ad24f447dd6c31bbab541e59e207bf029db359f0a82608db2e06b953b36d0c9a473a00458117ca32a5b0f4563a7d53963600000000000000000000000000000000000000000000000000000000000001000000000000000000000000000000000000000000000000000000000000000120000000000000000000000000000000000000000000000000000000000000001b7465616c2d31352d332e746f7275736e6f64652e636f6d3a343433000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000"}"#.utf8),
        statusCode: 200,
        responseHeaders: mustDecodeJSON(#"{"Date":"Sun, 17 Oct 2021 10:57:31 GMT","Vary":"Accept-Encoding, Origin","Content-Type":"application/json","Content-Length":"678"}"#) as! [String: String]
    ),

    Stub(
        requestMatcher: stubMatcherWithBody(
            host: "ropsten.infura.io",
            scheme: "https",
            path: "/v3/b8cdb0e4cff24599a286bf8e87ff1c96",
            method: "POST",
            requestHeaders: mustDecodeJSON(#"{"Accept":"application/json","Content-Type":"application/json"}"#) as! [String: String],
            body: mustDecodeJSON(#"{"jsonrpc":"2.0","method":"eth_call","id":1,"params":[{"to":"0x4023d2a0d330bf11426b12c6144cfb96b7fa6183","data":"0xbafb358100000000000000000000000057f7a525608dc540fefc3e851700a4189d19142d"},"latest"]}"#)
        ),
        responseBody: Data(#"{"jsonrpc":"2.0","id":1,"result":"0x00000000000000000000000000000000000000000000000000000000000000c00000000000000000000000000000000000000000000000000000000000000005d908f41f8e06324a8a7abcf702adb6a273ce3ae63d86a3d22723e1bbf1438c9af977530b3ec0e525438c72d1e768380cbc5fb3b38a760ee925053b2e169428ce00000000000000000000000000000000000000000000000000000000000001000000000000000000000000000000000000000000000000000000000000000120000000000000000000000000000000000000000000000000000000000000001b7465616c2d31352d322e746f7275736e6f64652e636f6d3a343433000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000"}"#.utf8),
        statusCode: 200,
        responseHeaders: mustDecodeJSON(#"{"Vary":"Accept-Encoding, Origin","Content-Length":"678","Content-Type":"application/json","Date":"Sun, 17 Oct 2021 10:57:31 GMT"}"#) as! [String: String]
    ),

    Stub(
        requestMatcher: stubMatcherWithBody(
            host: "ropsten.infura.io",
            scheme: "https",
            path: "/v3/b8cdb0e4cff24599a286bf8e87ff1c96",
            method: "POST",
            requestHeaders: mustDecodeJSON(#"{"Accept":"application/json","Content-Type":"application/json"}"#) as! [String: String],
            body: mustDecodeJSON(#"{"jsonrpc":"2.0","method":"eth_call","id":1,"params":[{"to":"0x4023d2a0d330bf11426b12c6144cfb96b7fa6183","data":"0xbafb3581000000000000000000000000e3c0493536f20d090c8f9427d8fdfe548af32662"},"latest"]}"#)
        ),
        responseBody: Data(#"{"jsonrpc":"2.0","id":1,"result":"0x00000000000000000000000000000000000000000000000000000000000000c000000000000000000000000000000000000000000000000000000000000000038a86543ca17df5687719e2549caa024cf17fe0361e119e741eaee668f8dd0a6f9cdb254ff915a76950d6d13d78ef054d5d0dc34e2908c00bb009a6e4da70189100000000000000000000000000000000000000000000000000000000000001000000000000000000000000000000000000000000000000000000000000000120000000000000000000000000000000000000000000000000000000000000001b7465616c2d31352d342e746f7275736e6f64652e636f6d3a343433000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000"}"#.utf8),
        statusCode: 200,
        responseHeaders: mustDecodeJSON(#"{"Date":"Sun, 17 Oct 2021 10:57:31 GMT","Content-Length":"678","Content-Type":"application/json","Vary":"Accept-Encoding, Origin"}"#) as! [String: String]
    ),

    Stub(
        requestMatcher: stubMatcherWithBody(
            host: "teal-15-4.torusnode.com",
            scheme: "https",
            path: "/jrpc",
            method: "POST",
            requestHeaders: mustDecodeJSON(#"{"Accept":"application/json","Content-Type":"application/json"}"#) as! [String: String],
            body: mustDecodeJSON(#"{"jsonrpc":"2.0","method":"VerifierLookupRequest","id":10,"params":{"verifier":"torus-direct-mock-ios","verifier_id":"michael@tor.us"}}"#)
        ),
        responseBody: Data(#"{"jsonrpc":"2.0","result":{"keys":[{"key_index":"1c724","pub_key_X":"22d225892d5d149c0486bfb358b143568d1a951c39d5ada061a48c06c48afe39","pub_key_Y":"fcd9074bff4b5097489b79f951146d66bbcd05dc6acf68b8d0afc271fb73cf64","address":"0x22f2Ce611cE0d0ff4DA661d3a4C4B7A60B2b13F8"}]},"id":10}"#.utf8),
        statusCode: 200,
        responseHeaders: mustDecodeJSON(#"{"Vary":"Origin","Server":"nginx/1.19.9","Content-Length":"281","Content-Type":"application/json","Date":"Sun, 17 Oct 2021 10:57:32 GMT"}"#) as! [String: String]
    ),

    Stub(
        requestMatcher: stubMatcherWithBody(
            host: "teal-15-2.torusnode.com",
            scheme: "https",
            path: "/jrpc",
            method: "POST",
            requestHeaders: mustDecodeJSON(#"{"Content-Type":"application/json","Accept":"application/json"}"#) as! [String: String],
            body: mustDecodeJSON(#"{"jsonrpc":"2.0","method":"VerifierLookupRequest","id":10,"params":{"verifier":"torus-direct-mock-ios","verifier_id":"michael@tor.us"}}"#)
        ),
        responseBody: Data(#"{"jsonrpc":"2.0","result":{"keys":[{"key_index":"1c724","pub_key_X":"22d225892d5d149c0486bfb358b143568d1a951c39d5ada061a48c06c48afe39","pub_key_Y":"fcd9074bff4b5097489b79f951146d66bbcd05dc6acf68b8d0afc271fb73cf64","address":"0x22f2Ce611cE0d0ff4DA661d3a4C4B7A60B2b13F8"}]},"id":10}"#.utf8),
        statusCode: 200,
        responseHeaders: mustDecodeJSON(#"{"Vary":"Origin","Server":"nginx/1.19.9","Content-Length":"281","Content-Type":"application/json","Date":"Sun, 17 Oct 2021 10:57:32 GMT"}"#) as! [String: String]
    ),

    Stub(
        requestMatcher: stubMatcherWithBody(
            host: "teal-15-1.torusnode.com",
            scheme: "https",
            path: "/jrpc",
            method: "POST",
            requestHeaders: mustDecodeJSON(#"{"Accept":"application/json","Content-Type":"application/json"}"#) as! [String: String],
            body: mustDecodeJSON(#"{"jsonrpc":"2.0","method":"VerifierLookupRequest","id":10,"params":{"verifier":"torus-direct-mock-ios","verifier_id":"michael@tor.us"}}"#)
        ),
        responseBody: Data(#"{"jsonrpc":"2.0","result":{"keys":[{"key_index":"1c724","pub_key_X":"22d225892d5d149c0486bfb358b143568d1a951c39d5ada061a48c06c48afe39","pub_key_Y":"fcd9074bff4b5097489b79f951146d66bbcd05dc6acf68b8d0afc271fb73cf64","address":"0x22f2Ce611cE0d0ff4DA661d3a4C4B7A60B2b13F8"}]},"id":10}"#.utf8),
        statusCode: 200,
        responseHeaders: mustDecodeJSON(#"{"Content-Length":"281","Vary":"Origin","Content-Type":"application/json","Server":"nginx/1.19.9","Date":"Sun, 17 Oct 2021 10:57:32 GMT"}"#) as! [String: String]
    ),

    Stub(
        requestMatcher: stubMatcherWithBody(
            host: "teal-15-3.torusnode.com",
            scheme: "https",
            path: "/jrpc",
            method: "POST",
            requestHeaders: mustDecodeJSON(#"{"Accept":"application/json","Content-Type":"application/json"}"#) as! [String: String],
            body: mustDecodeJSON(#"{"jsonrpc":"2.0","method":"VerifierLookupRequest","id":10,"params":{"verifier":"torus-direct-mock-ios","verifier_id":"michael@tor.us"}}"#)
        ),
        responseBody: Data(#"{"jsonrpc":"2.0","result":{"keys":[{"key_index":"1c724","pub_key_X":"22d225892d5d149c0486bfb358b143568d1a951c39d5ada061a48c06c48afe39","pub_key_Y":"fcd9074bff4b5097489b79f951146d66bbcd05dc6acf68b8d0afc271fb73cf64","address":"0x22f2Ce611cE0d0ff4DA661d3a4C4B7A60B2b13F8"}]},"id":10}"#.utf8),
        statusCode: 200,
        responseHeaders: mustDecodeJSON(#"{"Date":"Sun, 17 Oct 2021 10:57:32 GMT","Content-Length":"281","Content-Type":"application/json","Server":"nginx/1.19.9","Vary":"Origin"}"#) as! [String: String]
    ),

    Stub(
        requestMatcher: stubMatcher(
            host: "signer.tor.us",
            scheme: "https",
            path: "/api/allow",
            method: "GET",
            requestHeaders: mustDecodeJSON(#"{"Origin":"torus-direct-mock-ios","Accept":"application/json","Content-Type":"application/json","x-api-key":"torus-default"}"#) as! [String: String]
        ),
        responseBody: Data(#"{"success":true}"#.utf8),
        statusCode: 200,
        responseHeaders: mustDecodeJSON(#"{"Content-Length":"16","access-control-allow-headers":"pubkeyx,pubkeyy,x-api-key,x-embed-host,content-type,authorization,verifier,verifier_id","access-control-max-age":"86400","access-control-allow-methods":"GET,OPTIONS","Access-Control-Allow-Origin":"*","Date":"Sun, 17 Oct 2021 10:57:32 GMT","Content-Type":"application/json"}"#) as! [String: String]
    ),

    Stub(
        requestMatcher: stubMatcherWithBody(
            host: "teal-15-5.torusnode.com",
            scheme: "https",
            path: "/jrpc",
            method: "POST",
            requestHeaders: mustDecodeJSON(#"{"Accept":"application/json","Content-Type":"application/json"}"#) as! [String: String],
            body: mustDecodeJSON(#"{"jsonrpc":"2.0","method":"VerifierLookupRequest","id":10,"params":{"verifier":"torus-direct-mock-ios","verifier_id":"michael@tor.us"}}"#)
        ),
        responseBody: Data(#"{"jsonrpc":"2.0","result":{"keys":[{"key_index":"1c724","pub_key_X":"22d225892d5d149c0486bfb358b143568d1a951c39d5ada061a48c06c48afe39","pub_key_Y":"fcd9074bff4b5097489b79f951146d66bbcd05dc6acf68b8d0afc271fb73cf64","address":"0x22f2Ce611cE0d0ff4DA661d3a4C4B7A60B2b13F8"}]},"id":10}"#.utf8),
        statusCode: 200,
        responseHeaders: mustDecodeJSON(#"{"Vary":"Origin","Content-Length":"281","Server":"nginx/1.19.9","Content-Type":"application/json","Date":"Sun, 17 Oct 2021 10:57:32 GMT"}"#) as! [String: String]
    ),

    Stub(
        requestMatcher: stubMatcherWithBody(
            host: "metadata.tor.us",
            scheme: "https",
            path: "/get",
            method: "POST",
            requestHeaders: mustDecodeJSON(#"{"Content-Type":"application/json","Accept":"application/json"}"#) as! [String: String],
            body: mustDecodeJSON(#"{"pub_key_X":"22d225892d5d149c0486bfb358b143568d1a951c39d5ada061a48c06c48afe39","pub_key_Y":"fcd9074bff4b5097489b79f951146d66bbcd05dc6acf68b8d0afc271fb73cf64"}"#)
        ),
        responseBody: Data(#"{"message":""}"#.utf8),
        statusCode: 200,
        responseHeaders: mustDecodeJSON(#"{"x-download-options":"noopen","x-permitted-cross-domain-policies":"none","x-content-type-options":"nosniff","Strict-Transport-Security":"max-age=15552000; includeSubDomains","x-dns-prefetch-control":"off","x-xss-protection":"0","content-security-policy":"default-src 'self';base-uri 'self';block-all-mixed-content;font-src 'self' https: data:;frame-ancestors 'self';img-src 'self' data:;object-src 'none';script-src 'self';script-src-attr 'none';style-src 'self' https: 'unsafe-inline';upgrade-insecure-requests","x-frame-options":"SAMEORIGIN","referrer-policy":"no-referrer","Date":"Sun, 17 Oct 2021 10:57:32 GMT","Content-Type":"application/json; charset=utf-8","expect-ct":"max-age=0","Etag":"W/\"e-JWOqSwGs6lhRJiUZe/mVb6Mua74\"","Content-Length":"14","Vary":"Origin, Accept-Encoding"}"#) as! [String: String]
    ),

    Stub(
        requestMatcher: stubMatcherWithBody(
            host: "teal-15-1.torusnode.com",
            scheme: "https",
            path: "/jrpc",
            method: "POST",
            requestHeaders: mustDecodeJSON(#"{"Accept":"application/json","Content-Type":"application/json"}"#) as! [String: String],
            body: mustDecodeJSON(#"{"jsonrpc":"2.0","method":"CommitmentRequest","id":10,"params":{"messageprefix":"mug00","temppuby":"03b18e36aa6c864091cd7d6536d30a3808c772f18479d753e12847266144c10e","temppubx":"3b695585f9c5ac4a4f036757c8873d01f51b68d5e8f0274e2dc4ebbc7daa7025","tokencommitment":"f9a9e61d68072c950e5dc8baf824b810d52073e9e3748e35f9a534502bac8a5b","timestamp":"0","verifieridentifier":"torus-direct-mock-ios"}}"#)
        ),
        responseBody: Data(#"{"jsonrpc":"2.0","result":{"signature":"f94f88b5a2fff06463fe0cb4569a652a11f351061dcd5b15e466274e374eb2992632153bda0c017d9c83916b82f1daa3ee5ac9990201d73a18915224a828b6a41b","data":"mug00\u001cf9a9e61d68072c950e5dc8baf824b810d52073e9e3748e35f9a534502bac8a5b\u001c3b695585f9c5ac4a4f036757c8873d01f51b68d5e8f0274e2dc4ebbc7daa7025\u001c03b18e36aa6c864091cd7d6536d30a3808c772f18479d753e12847266144c10e\u001ctorus-direct-mock-ios\u001c1634468252","nodepubx":"1363aad8868cacd7f8946c590325cd463106fb3731f08811ab4302d2deae35c3","nodepuby":"d77eebe5cdf466b475ec892d5b4cffbe0c1670525debbd97eee6dae2f87a7cbe"},"id":10}"#.utf8),
        statusCode: 200,
        responseHeaders: mustDecodeJSON(#"{"Server":"nginx/1.19.9","Content-Type":"application/json","Vary":"Origin","Date":"Sun, 17 Oct 2021 10:57:32 GMT","Content-Length":"606"}"#) as! [String: String]
    ),

    Stub(
        requestMatcher: stubMatcherWithBody(
            host: "teal-15-3.torusnode.com",
            scheme: "https",
            path: "/jrpc",
            method: "POST",
            requestHeaders: mustDecodeJSON(#"{"Content-Type":"application/json","Accept":"application/json"}"#) as! [String: String],
            body: mustDecodeJSON(#"{"jsonrpc":"2.0","method":"CommitmentRequest","id":10,"params":{"messageprefix":"mug00","temppuby":"03b18e36aa6c864091cd7d6536d30a3808c772f18479d753e12847266144c10e","temppubx":"3b695585f9c5ac4a4f036757c8873d01f51b68d5e8f0274e2dc4ebbc7daa7025","tokencommitment":"f9a9e61d68072c950e5dc8baf824b810d52073e9e3748e35f9a534502bac8a5b","timestamp":"0","verifieridentifier":"torus-direct-mock-ios"}}"#)
        ),
        responseBody: Data(#"{"jsonrpc":"2.0","result":{"signature":"ee5b3560bc5b394326ddb784970eb27c995b77ceac9ce04ddffe72a52542dffd7b90b30c50b69481b43f04a0373b632798bac8fcdf8d695ead606200e0a24fc41c","data":"mug00\u001cf9a9e61d68072c950e5dc8baf824b810d52073e9e3748e35f9a534502bac8a5b\u001c3b695585f9c5ac4a4f036757c8873d01f51b68d5e8f0274e2dc4ebbc7daa7025\u001c03b18e36aa6c864091cd7d6536d30a3808c772f18479d753e12847266144c10e\u001ctorus-direct-mock-ios\u001c1634468252","nodepubx":"7c8cc521c48690f016bea593f67f88ad24f447dd6c31bbab541e59e207bf029d","nodepuby":"b359f0a82608db2e06b953b36d0c9a473a00458117ca32a5b0f4563a7d539636"},"id":10}"#.utf8),
        statusCode: 200,
        responseHeaders: mustDecodeJSON(#"{"Server":"nginx/1.19.9","Content-Type":"application/json","Vary":"Origin","Date":"Sun, 17 Oct 2021 10:57:32 GMT","Content-Length":"606"}"#) as! [String: String]
    ),

    Stub(
        requestMatcher: stubMatcherWithBody(
            host: "teal-15-4.torusnode.com",
            scheme: "https",
            path: "/jrpc",
            method: "POST",
            requestHeaders: mustDecodeJSON(#"{"Accept":"application/json","Content-Type":"application/json"}"#) as! [String: String],
            body: mustDecodeJSON(#"{"jsonrpc":"2.0","method":"CommitmentRequest","id":10,"params":{"messageprefix":"mug00","temppuby":"03b18e36aa6c864091cd7d6536d30a3808c772f18479d753e12847266144c10e","temppubx":"3b695585f9c5ac4a4f036757c8873d01f51b68d5e8f0274e2dc4ebbc7daa7025","tokencommitment":"f9a9e61d68072c950e5dc8baf824b810d52073e9e3748e35f9a534502bac8a5b","timestamp":"0","verifieridentifier":"torus-direct-mock-ios"}}"#)
        ),
        responseBody: Data(#"{"jsonrpc":"2.0","result":{"signature":"739487dab15bc238d32db83faf7b0aeb57f6863ac079aa331605eee9e076567c5cfa588978128af9d2c160d92a30197ccec8ab8c24ea68a3ac540a2534f65e261c","data":"mug00\u001cf9a9e61d68072c950e5dc8baf824b810d52073e9e3748e35f9a534502bac8a5b\u001c3b695585f9c5ac4a4f036757c8873d01f51b68d5e8f0274e2dc4ebbc7daa7025\u001c03b18e36aa6c864091cd7d6536d30a3808c772f18479d753e12847266144c10e\u001ctorus-direct-mock-ios\u001c1634468252","nodepubx":"8a86543ca17df5687719e2549caa024cf17fe0361e119e741eaee668f8dd0a6f","nodepuby":"9cdb254ff915a76950d6d13d78ef054d5d0dc34e2908c00bb009a6e4da701891"},"id":10}"#.utf8),
        statusCode: 200,
        responseHeaders: mustDecodeJSON(#"{"Vary":"Origin","Server":"nginx/1.19.9","Content-Length":"606","Content-Type":"application/json","Date":"Sun, 17 Oct 2021 10:57:32 GMT"}"#) as! [String: String]
    ),

    Stub(
        requestMatcher: stubMatcherWithBody(
            host: "teal-15-5.torusnode.com",
            scheme: "https",
            path: "/jrpc",
            method: "POST",
            requestHeaders: mustDecodeJSON(#"{"Content-Type":"application/json","Accept":"application/json"}"#) as! [String: String],
            body: mustDecodeJSON(#"{"jsonrpc":"2.0","method":"CommitmentRequest","id":10,"params":{"messageprefix":"mug00","temppuby":"03b18e36aa6c864091cd7d6536d30a3808c772f18479d753e12847266144c10e","temppubx":"3b695585f9c5ac4a4f036757c8873d01f51b68d5e8f0274e2dc4ebbc7daa7025","tokencommitment":"f9a9e61d68072c950e5dc8baf824b810d52073e9e3748e35f9a534502bac8a5b","timestamp":"0","verifieridentifier":"torus-direct-mock-ios"}}"#)
        ),
        responseBody: Data(#"{"jsonrpc":"2.0","result":{"signature":"d24ccf58546df41bc8506b467e017ec64d941feb442a02001bea1c014dbe4d6b01317473884284d038ea116e6040ab25dad9901ee94d41dd33674cd105bc32151b","data":"mug00\u001cf9a9e61d68072c950e5dc8baf824b810d52073e9e3748e35f9a534502bac8a5b\u001c3b695585f9c5ac4a4f036757c8873d01f51b68d5e8f0274e2dc4ebbc7daa7025\u001c03b18e36aa6c864091cd7d6536d30a3808c772f18479d753e12847266144c10e\u001ctorus-direct-mock-ios\u001c1634468252","nodepubx":"25a98d9ae006aed1d77e81d58be8f67193d13d01a9888e2923841894f4b0bf9c","nodepuby":"f63d40df480dacf68922004ed36dbab9e2969181b047730a5ce0797fb6958249"},"id":10}"#.utf8),
        statusCode: 200,
        responseHeaders: mustDecodeJSON(#"{"Vary":"Origin","Server":"nginx/1.19.9","Content-Length":"606","Content-Type":"application/json","Date":"Sun, 17 Oct 2021 10:57:32 GMT"}"#) as! [String: String]
    ),

    Stub(
        requestMatcher: stubMatcherWithBody(
            host: "teal-15-2.torusnode.com",
            scheme: "https",
            path: "/jrpc",
            method: "POST",
            requestHeaders: mustDecodeJSON(#"{"Accept":"application/json","Content-Type":"application/json"}"#) as! [String: String],
            body: mustDecodeJSON(#"{"jsonrpc":"2.0","method":"CommitmentRequest","id":10,"params":{"messageprefix":"mug00","temppuby":"03b18e36aa6c864091cd7d6536d30a3808c772f18479d753e12847266144c10e","temppubx":"3b695585f9c5ac4a4f036757c8873d01f51b68d5e8f0274e2dc4ebbc7daa7025","tokencommitment":"f9a9e61d68072c950e5dc8baf824b810d52073e9e3748e35f9a534502bac8a5b","timestamp":"0","verifieridentifier":"torus-direct-mock-ios"}}"#)
        ),
        responseBody: Data(#"{"jsonrpc":"2.0","result":{"signature":"ed5d0191d91c02b427d6482cec5d5380026218a1adecfefd6f892903577abb5d43f303302b1eac90b7d225beeb66c8c9ed9ebde8ccfe5994b3fb5f028cf571411c","data":"mug00\u001cf9a9e61d68072c950e5dc8baf824b810d52073e9e3748e35f9a534502bac8a5b\u001c3b695585f9c5ac4a4f036757c8873d01f51b68d5e8f0274e2dc4ebbc7daa7025\u001c03b18e36aa6c864091cd7d6536d30a3808c772f18479d753e12847266144c10e\u001ctorus-direct-mock-ios\u001c1634468252","nodepubx":"d908f41f8e06324a8a7abcf702adb6a273ce3ae63d86a3d22723e1bbf1438c9a","nodepuby":"f977530b3ec0e525438c72d1e768380cbc5fb3b38a760ee925053b2e169428ce"},"id":10}"#.utf8),
        statusCode: 200,
        responseHeaders: mustDecodeJSON(#"{"Server":"nginx/1.19.9","Content-Length":"606","Content-Type":"application/json","Vary":"Origin","Date":"Sun, 17 Oct 2021 10:57:32 GMT"}"#) as! [String: String]
    ),

    Stub(
        requestMatcher: stubMatcherWithBody(
            host: "teal-15-3.torusnode.com",
            scheme: "https",
            path: "/jrpc",
            method: "POST",
            requestHeaders: mustDecodeJSON(#"{"Accept":"application/json","Content-Type":"application/json"}"#) as! [String: String],
            body: mustDecodeJSON(#"{"params":{"encrypted":"yes","item":[{"verifieridentifier":"torus-direct-mock-ios","nodesignatures":[{"signature":"f94f88b5a2fff06463fe0cb4569a652a11f351061dcd5b15e466274e374eb2992632153bda0c017d9c83916b82f1daa3ee5ac9990201d73a18915224a828b6a41b","nodepubx":"1363aad8868cacd7f8946c590325cd463106fb3731f08811ab4302d2deae35c3","data":"mug00\u001cf9a9e61d68072c950e5dc8baf824b810d52073e9e3748e35f9a534502bac8a5b\u001c3b695585f9c5ac4a4f036757c8873d01f51b68d5e8f0274e2dc4ebbc7daa7025\u001c03b18e36aa6c864091cd7d6536d30a3808c772f18479d753e12847266144c10e\u001ctorus-direct-mock-ios\u001c1634468252","nodepuby":"d77eebe5cdf466b475ec892d5b4cffbe0c1670525debbd97eee6dae2f87a7cbe"},{"nodepubx":"7c8cc521c48690f016bea593f67f88ad24f447dd6c31bbab541e59e207bf029d","nodepuby":"b359f0a82608db2e06b953b36d0c9a473a00458117ca32a5b0f4563a7d539636","data":"mug00\u001cf9a9e61d68072c950e5dc8baf824b810d52073e9e3748e35f9a534502bac8a5b\u001c3b695585f9c5ac4a4f036757c8873d01f51b68d5e8f0274e2dc4ebbc7daa7025\u001c03b18e36aa6c864091cd7d6536d30a3808c772f18479d753e12847266144c10e\u001ctorus-direct-mock-ios\u001c1634468252","signature":"ee5b3560bc5b394326ddb784970eb27c995b77ceac9ce04ddffe72a52542dffd7b90b30c50b69481b43f04a0373b632798bac8fcdf8d695ead606200e0a24fc41c"},{"signature":"739487dab15bc238d32db83faf7b0aeb57f6863ac079aa331605eee9e076567c5cfa588978128af9d2c160d92a30197ccec8ab8c24ea68a3ac540a2534f65e261c","nodepubx":"8a86543ca17df5687719e2549caa024cf17fe0361e119e741eaee668f8dd0a6f","data":"mug00\u001cf9a9e61d68072c950e5dc8baf824b810d52073e9e3748e35f9a534502bac8a5b\u001c3b695585f9c5ac4a4f036757c8873d01f51b68d5e8f0274e2dc4ebbc7daa7025\u001c03b18e36aa6c864091cd7d6536d30a3808c772f18479d753e12847266144c10e\u001ctorus-direct-mock-ios\u001c1634468252","nodepuby":"9cdb254ff915a76950d6d13d78ef054d5d0dc34e2908c00bb009a6e4da701891"},{"data":"mug00\u001cf9a9e61d68072c950e5dc8baf824b810d52073e9e3748e35f9a534502bac8a5b\u001c3b695585f9c5ac4a4f036757c8873d01f51b68d5e8f0274e2dc4ebbc7daa7025\u001c03b18e36aa6c864091cd7d6536d30a3808c772f18479d753e12847266144c10e\u001ctorus-direct-mock-ios\u001c1634468252","signature":"d24ccf58546df41bc8506b467e017ec64d941feb442a02001bea1c014dbe4d6b01317473884284d038ea116e6040ab25dad9901ee94d41dd33674cd105bc32151b","nodepuby":"f63d40df480dacf68922004ed36dbab9e2969181b047730a5ce0797fb6958249","nodepubx":"25a98d9ae006aed1d77e81d58be8f67193d13d01a9888e2923841894f4b0bf9c"}],"verifier_id":"michael@tor.us","idtoken":"eyJhbGciOiJSUzI1NiIsImtpZCI6ImFkZDhjMGVlNjIzOTU0NGFmNTNmOTM3MTJhNTdiMmUyNmY5NDMzNTIiLCJ0eXAiOiJKV1QifQ.eyJpc3MiOiJodHRwczovL2FjY291bnRzLmdvb2dsZS5jb20iLCJhenAiOiI2MzYxOTk0NjUyNDItZmQ3dWp0b3JwdnZ1ZHRzbDN1M2V2OTBuaWplY3RmcW0uYXBwcy5nb29nbGV1c2VyY29udGVudC5jb20iLCJhdWQiOiI2MzYxOTk0NjUyNDItZmQ3dWp0b3JwdnZ1ZHRzbDN1M2V2OTBuaWplY3RmcW0uYXBwcy5nb29nbGV1c2VyY29udGVudC5jb20iLCJzdWIiOiIxMDkxMTE5NTM4NTYwMzE3OTk2MzkiLCJoZCI6InRvci51cyIsImVtYWlsIjoibWljaGFlbEB0b3IudXMiLCJlbWFpbF92ZXJpZmllZCI6dHJ1ZSwiYXRfaGFzaCI6InRUNDhSck1vdGFFbi1UN3dzc2U3QnciLCJub25jZSI6InZSU2tPZWwyQTkiLCJuYW1lIjoiTWljaGFlbCBMZWUiLCJwaWN0dXJlIjoiaHR0cHM6Ly9saDMuZ29vZ2xldXNlcmNvbnRlbnQuY29tL2EvQUFUWEFKd3NCYjk4Z1NZalZObEJCQWhYSmp2cU5PdzJHRFNlVGYwSTZTSmg9czk2LWMiLCJnaXZlbl9uYW1lIjoiTWljaGFlbCIsImZhbWlseV9uYW1lIjoiTGVlIiwibG9jYWxlIjoiZW4iLCJpYXQiOjE2MzQ0NjgyNDksImV4cCI6MTYzNDQ3MTg0OX0.XGu1tm_OqlSrc5BMDMzOrlhxLZo1YnpCUT0_j2U1mQt86nJzf_Hp85JfapZj2QeeUz91H6-Ei8FR1i4ICEfjMcoZOW1Azc89qUNfUgWeyjqZ7wCHSsbHAwabE74RFAS9YAja8_ynUvCARfDEtoqcreNgmbw3ZntzAqpuuNBXYfbr87kMvu_wZ7fWjLKM91CvuXytQBwtieTyjAFnTXmEL60Pdu-JSQfHCbS5H39ZHlnYxEO6qztIjvbnQokhjHDGc4PMCx0wfzrEet1ojNOCnbfmaYE5NQudquzQNZtqZfn8f4B-sQhECElnOXagHlafWO5RayS0dCb1mTfr8orcCA"}]},"id":10,"method":"ShareRequest","jsonrpc":"2.0"}"#)
        ),
        responseBody: Data(#"{"jsonrpc":"2.0","result":{"keys":[{"Index":"1c724","PublicKey":{"X":"22d225892d5d149c0486bfb358b143568d1a951c39d5ada061a48c06c48afe39","Y":"fcd9074bff4b5097489b79f951146d66bbcd05dc6acf68b8d0afc271fb73cf64"},"Threshold":1,"Verifiers":{"torus-direct-mock-ios":["michael@tor.us"]},"Share":"NGNmMDY4M2M0ZjVlMzAzZTE1YWE0YWU3NDQwZjJiNWQ2ZWVkN2U2MjcxZGQ3MjVjMTA2OGY5Njk3MTM0ODRmNmFmYjQwNjhhYjkyMGM3MTY0MWFjNWZjYTBiMGVhMTQw","Metadata":{"iv":"95d1859aa5f86d87f13ed672d12e2d10","ephemPublicKey":"0403aa155f2605555d7399378e71146420e8d4eac9fd911ee57134da846f0e1e60702397386f0ec1226c2e7616283739922d9b654570bce4fd775021ee7bfb6451","mac":"aabadefa3f0d1d7530425595e2b54faaafb9ee3e3ff7c8ad14f8f8572095ba4e","mode":"AES256"}}]},"id":10}"#.utf8),
        statusCode: 200,
        responseHeaders: mustDecodeJSON(#"{"Vary":"Origin","Content-Length":"722","Date":"Sun, 17 Oct 2021 10:57:32 GMT","Content-Type":"application/json","Server":"nginx/1.19.9"}"#) as! [String: String]
    ),

    Stub(
        requestMatcher: stubMatcherWithBody(
            host: "teal-15-1.torusnode.com",
            scheme: "https",
            path: "/jrpc",
            method: "POST",
            requestHeaders: mustDecodeJSON(#"{"Content-Type":"application/json","Accept":"application/json"}"#) as! [String: String],
            body: mustDecodeJSON(#"{"params":{"encrypted":"yes","item":[{"verifieridentifier":"torus-direct-mock-ios","nodesignatures":[{"signature":"f94f88b5a2fff06463fe0cb4569a652a11f351061dcd5b15e466274e374eb2992632153bda0c017d9c83916b82f1daa3ee5ac9990201d73a18915224a828b6a41b","nodepubx":"1363aad8868cacd7f8946c590325cd463106fb3731f08811ab4302d2deae35c3","data":"mug00\u001cf9a9e61d68072c950e5dc8baf824b810d52073e9e3748e35f9a534502bac8a5b\u001c3b695585f9c5ac4a4f036757c8873d01f51b68d5e8f0274e2dc4ebbc7daa7025\u001c03b18e36aa6c864091cd7d6536d30a3808c772f18479d753e12847266144c10e\u001ctorus-direct-mock-ios\u001c1634468252","nodepuby":"d77eebe5cdf466b475ec892d5b4cffbe0c1670525debbd97eee6dae2f87a7cbe"},{"nodepubx":"7c8cc521c48690f016bea593f67f88ad24f447dd6c31bbab541e59e207bf029d","nodepuby":"b359f0a82608db2e06b953b36d0c9a473a00458117ca32a5b0f4563a7d539636","data":"mug00\u001cf9a9e61d68072c950e5dc8baf824b810d52073e9e3748e35f9a534502bac8a5b\u001c3b695585f9c5ac4a4f036757c8873d01f51b68d5e8f0274e2dc4ebbc7daa7025\u001c03b18e36aa6c864091cd7d6536d30a3808c772f18479d753e12847266144c10e\u001ctorus-direct-mock-ios\u001c1634468252","signature":"ee5b3560bc5b394326ddb784970eb27c995b77ceac9ce04ddffe72a52542dffd7b90b30c50b69481b43f04a0373b632798bac8fcdf8d695ead606200e0a24fc41c"},{"signature":"739487dab15bc238d32db83faf7b0aeb57f6863ac079aa331605eee9e076567c5cfa588978128af9d2c160d92a30197ccec8ab8c24ea68a3ac540a2534f65e261c","nodepubx":"8a86543ca17df5687719e2549caa024cf17fe0361e119e741eaee668f8dd0a6f","data":"mug00\u001cf9a9e61d68072c950e5dc8baf824b810d52073e9e3748e35f9a534502bac8a5b\u001c3b695585f9c5ac4a4f036757c8873d01f51b68d5e8f0274e2dc4ebbc7daa7025\u001c03b18e36aa6c864091cd7d6536d30a3808c772f18479d753e12847266144c10e\u001ctorus-direct-mock-ios\u001c1634468252","nodepuby":"9cdb254ff915a76950d6d13d78ef054d5d0dc34e2908c00bb009a6e4da701891"},{"data":"mug00\u001cf9a9e61d68072c950e5dc8baf824b810d52073e9e3748e35f9a534502bac8a5b\u001c3b695585f9c5ac4a4f036757c8873d01f51b68d5e8f0274e2dc4ebbc7daa7025\u001c03b18e36aa6c864091cd7d6536d30a3808c772f18479d753e12847266144c10e\u001ctorus-direct-mock-ios\u001c1634468252","signature":"d24ccf58546df41bc8506b467e017ec64d941feb442a02001bea1c014dbe4d6b01317473884284d038ea116e6040ab25dad9901ee94d41dd33674cd105bc32151b","nodepuby":"f63d40df480dacf68922004ed36dbab9e2969181b047730a5ce0797fb6958249","nodepubx":"25a98d9ae006aed1d77e81d58be8f67193d13d01a9888e2923841894f4b0bf9c"}],"verifier_id":"michael@tor.us","idtoken":"eyJhbGciOiJSUzI1NiIsImtpZCI6ImFkZDhjMGVlNjIzOTU0NGFmNTNmOTM3MTJhNTdiMmUyNmY5NDMzNTIiLCJ0eXAiOiJKV1QifQ.eyJpc3MiOiJodHRwczovL2FjY291bnRzLmdvb2dsZS5jb20iLCJhenAiOiI2MzYxOTk0NjUyNDItZmQ3dWp0b3JwdnZ1ZHRzbDN1M2V2OTBuaWplY3RmcW0uYXBwcy5nb29nbGV1c2VyY29udGVudC5jb20iLCJhdWQiOiI2MzYxOTk0NjUyNDItZmQ3dWp0b3JwdnZ1ZHRzbDN1M2V2OTBuaWplY3RmcW0uYXBwcy5nb29nbGV1c2VyY29udGVudC5jb20iLCJzdWIiOiIxMDkxMTE5NTM4NTYwMzE3OTk2MzkiLCJoZCI6InRvci51cyIsImVtYWlsIjoibWljaGFlbEB0b3IudXMiLCJlbWFpbF92ZXJpZmllZCI6dHJ1ZSwiYXRfaGFzaCI6InRUNDhSck1vdGFFbi1UN3dzc2U3QnciLCJub25jZSI6InZSU2tPZWwyQTkiLCJuYW1lIjoiTWljaGFlbCBMZWUiLCJwaWN0dXJlIjoiaHR0cHM6Ly9saDMuZ29vZ2xldXNlcmNvbnRlbnQuY29tL2EvQUFUWEFKd3NCYjk4Z1NZalZObEJCQWhYSmp2cU5PdzJHRFNlVGYwSTZTSmg9czk2LWMiLCJnaXZlbl9uYW1lIjoiTWljaGFlbCIsImZhbWlseV9uYW1lIjoiTGVlIiwibG9jYWxlIjoiZW4iLCJpYXQiOjE2MzQ0NjgyNDksImV4cCI6MTYzNDQ3MTg0OX0.XGu1tm_OqlSrc5BMDMzOrlhxLZo1YnpCUT0_j2U1mQt86nJzf_Hp85JfapZj2QeeUz91H6-Ei8FR1i4ICEfjMcoZOW1Azc89qUNfUgWeyjqZ7wCHSsbHAwabE74RFAS9YAja8_ynUvCARfDEtoqcreNgmbw3ZntzAqpuuNBXYfbr87kMvu_wZ7fWjLKM91CvuXytQBwtieTyjAFnTXmEL60Pdu-JSQfHCbS5H39ZHlnYxEO6qztIjvbnQokhjHDGc4PMCx0wfzrEet1ojNOCnbfmaYE5NQudquzQNZtqZfn8f4B-sQhECElnOXagHlafWO5RayS0dCb1mTfr8orcCA"}]},"id":10,"method":"ShareRequest","jsonrpc":"2.0"}"#)
        ),
        responseBody: Data(#"{"jsonrpc":"2.0","result":{"keys":[{"Index":"1c724","PublicKey":{"X":"22d225892d5d149c0486bfb358b143568d1a951c39d5ada061a48c06c48afe39","Y":"fcd9074bff4b5097489b79f951146d66bbcd05dc6acf68b8d0afc271fb73cf64"},"Threshold":1,"Verifiers":{"torus-direct-mock-ios":["michael@tor.us"]},"Share":"ZjBjNTEyNDI1MTBmOThiMGJjNDhhZjdhOTgwZjNkYTM0YjhmYmVkYzRjZTA2NzI1ZmI4MDExYWQ1MTc3YTUwNzFkYjNmNDNhYzA2NGNjYjkzYWIxYjY0YWZkY2I2NzMy","Metadata":{"iv":"e72d1cbaef1868cfbe241c3a84bb0a26","ephemPublicKey":"048b20e455385773ea58f59b0da8bde5cbe07f46155f6793fb120cd0fac8113ecf31adfcf5c07a8457d0973b93902c59fd156496ccf3746b9d44ce3de671360109","mac":"d9e7d9b565dc815a4969928296630bbc8102f080d3bcabb8f91df08f6cdb3f74","mode":"AES256"}}]},"id":10}"#.utf8),
        statusCode: 200,
        responseHeaders: mustDecodeJSON(#"{"Server":"nginx/1.19.9","Content-Length":"722","Vary":"Origin","Content-Type":"application/json","Date":"Sun, 17 Oct 2021 10:57:32 GMT"}"#) as! [String: String]
    ),

    Stub(
        requestMatcher: stubMatcherWithBody(
            host: "teal-15-5.torusnode.com",
            scheme: "https",
            path: "/jrpc",
            method: "POST",
            requestHeaders: mustDecodeJSON(#"{"Accept":"application/json","Content-Type":"application/json"}"#) as! [String: String],
            body: mustDecodeJSON(#"{"params":{"encrypted":"yes","item":[{"verifieridentifier":"torus-direct-mock-ios","nodesignatures":[{"signature":"f94f88b5a2fff06463fe0cb4569a652a11f351061dcd5b15e466274e374eb2992632153bda0c017d9c83916b82f1daa3ee5ac9990201d73a18915224a828b6a41b","nodepubx":"1363aad8868cacd7f8946c590325cd463106fb3731f08811ab4302d2deae35c3","data":"mug00\u001cf9a9e61d68072c950e5dc8baf824b810d52073e9e3748e35f9a534502bac8a5b\u001c3b695585f9c5ac4a4f036757c8873d01f51b68d5e8f0274e2dc4ebbc7daa7025\u001c03b18e36aa6c864091cd7d6536d30a3808c772f18479d753e12847266144c10e\u001ctorus-direct-mock-ios\u001c1634468252","nodepuby":"d77eebe5cdf466b475ec892d5b4cffbe0c1670525debbd97eee6dae2f87a7cbe"},{"nodepubx":"7c8cc521c48690f016bea593f67f88ad24f447dd6c31bbab541e59e207bf029d","nodepuby":"b359f0a82608db2e06b953b36d0c9a473a00458117ca32a5b0f4563a7d539636","data":"mug00\u001cf9a9e61d68072c950e5dc8baf824b810d52073e9e3748e35f9a534502bac8a5b\u001c3b695585f9c5ac4a4f036757c8873d01f51b68d5e8f0274e2dc4ebbc7daa7025\u001c03b18e36aa6c864091cd7d6536d30a3808c772f18479d753e12847266144c10e\u001ctorus-direct-mock-ios\u001c1634468252","signature":"ee5b3560bc5b394326ddb784970eb27c995b77ceac9ce04ddffe72a52542dffd7b90b30c50b69481b43f04a0373b632798bac8fcdf8d695ead606200e0a24fc41c"},{"signature":"739487dab15bc238d32db83faf7b0aeb57f6863ac079aa331605eee9e076567c5cfa588978128af9d2c160d92a30197ccec8ab8c24ea68a3ac540a2534f65e261c","nodepubx":"8a86543ca17df5687719e2549caa024cf17fe0361e119e741eaee668f8dd0a6f","data":"mug00\u001cf9a9e61d68072c950e5dc8baf824b810d52073e9e3748e35f9a534502bac8a5b\u001c3b695585f9c5ac4a4f036757c8873d01f51b68d5e8f0274e2dc4ebbc7daa7025\u001c03b18e36aa6c864091cd7d6536d30a3808c772f18479d753e12847266144c10e\u001ctorus-direct-mock-ios\u001c1634468252","nodepuby":"9cdb254ff915a76950d6d13d78ef054d5d0dc34e2908c00bb009a6e4da701891"},{"data":"mug00\u001cf9a9e61d68072c950e5dc8baf824b810d52073e9e3748e35f9a534502bac8a5b\u001c3b695585f9c5ac4a4f036757c8873d01f51b68d5e8f0274e2dc4ebbc7daa7025\u001c03b18e36aa6c864091cd7d6536d30a3808c772f18479d753e12847266144c10e\u001ctorus-direct-mock-ios\u001c1634468252","signature":"d24ccf58546df41bc8506b467e017ec64d941feb442a02001bea1c014dbe4d6b01317473884284d038ea116e6040ab25dad9901ee94d41dd33674cd105bc32151b","nodepuby":"f63d40df480dacf68922004ed36dbab9e2969181b047730a5ce0797fb6958249","nodepubx":"25a98d9ae006aed1d77e81d58be8f67193d13d01a9888e2923841894f4b0bf9c"}],"verifier_id":"michael@tor.us","idtoken":"eyJhbGciOiJSUzI1NiIsImtpZCI6ImFkZDhjMGVlNjIzOTU0NGFmNTNmOTM3MTJhNTdiMmUyNmY5NDMzNTIiLCJ0eXAiOiJKV1QifQ.eyJpc3MiOiJodHRwczovL2FjY291bnRzLmdvb2dsZS5jb20iLCJhenAiOiI2MzYxOTk0NjUyNDItZmQ3dWp0b3JwdnZ1ZHRzbDN1M2V2OTBuaWplY3RmcW0uYXBwcy5nb29nbGV1c2VyY29udGVudC5jb20iLCJhdWQiOiI2MzYxOTk0NjUyNDItZmQ3dWp0b3JwdnZ1ZHRzbDN1M2V2OTBuaWplY3RmcW0uYXBwcy5nb29nbGV1c2VyY29udGVudC5jb20iLCJzdWIiOiIxMDkxMTE5NTM4NTYwMzE3OTk2MzkiLCJoZCI6InRvci51cyIsImVtYWlsIjoibWljaGFlbEB0b3IudXMiLCJlbWFpbF92ZXJpZmllZCI6dHJ1ZSwiYXRfaGFzaCI6InRUNDhSck1vdGFFbi1UN3dzc2U3QnciLCJub25jZSI6InZSU2tPZWwyQTkiLCJuYW1lIjoiTWljaGFlbCBMZWUiLCJwaWN0dXJlIjoiaHR0cHM6Ly9saDMuZ29vZ2xldXNlcmNvbnRlbnQuY29tL2EvQUFUWEFKd3NCYjk4Z1NZalZObEJCQWhYSmp2cU5PdzJHRFNlVGYwSTZTSmg9czk2LWMiLCJnaXZlbl9uYW1lIjoiTWljaGFlbCIsImZhbWlseV9uYW1lIjoiTGVlIiwibG9jYWxlIjoiZW4iLCJpYXQiOjE2MzQ0NjgyNDksImV4cCI6MTYzNDQ3MTg0OX0.XGu1tm_OqlSrc5BMDMzOrlhxLZo1YnpCUT0_j2U1mQt86nJzf_Hp85JfapZj2QeeUz91H6-Ei8FR1i4ICEfjMcoZOW1Azc89qUNfUgWeyjqZ7wCHSsbHAwabE74RFAS9YAja8_ynUvCARfDEtoqcreNgmbw3ZntzAqpuuNBXYfbr87kMvu_wZ7fWjLKM91CvuXytQBwtieTyjAFnTXmEL60Pdu-JSQfHCbS5H39ZHlnYxEO6qztIjvbnQokhjHDGc4PMCx0wfzrEet1ojNOCnbfmaYE5NQudquzQNZtqZfn8f4B-sQhECElnOXagHlafWO5RayS0dCb1mTfr8orcCA"}]},"id":10,"method":"ShareRequest","jsonrpc":"2.0"}"#)
        ),
        responseBody: Data(#"{"jsonrpc":"2.0","result":{"keys":[{"Index":"1c724","PublicKey":{"X":"22d225892d5d149c0486bfb358b143568d1a951c39d5ada061a48c06c48afe39","Y":"fcd9074bff4b5097489b79f951146d66bbcd05dc6acf68b8d0afc271fb73cf64"},"Threshold":1,"Verifiers":{"torus-direct-mock-ios":["michael@tor.us"]},"Share":"MzUyMTg4ZjEyMzc1NDAwZjk0MDIxOTgyNGJjNjZkM2U1MmZmM2Y0YjJjZWFkOTQzN2M0N2ZjMjMxMDFkYzQ5YzY5NjZiZTUzM2MwMDg2NTE1OGRlNThiNDc5N2M5Yjgy","Metadata":{"iv":"c73e422b8c1ca9bbe10caa04d8d6e79d","ephemPublicKey":"046ac88f638dc83e4eef85b9bea2de984449ad7587cc5c652451632d2ecc1509b1fa43180768d9c6e5e513d48f2bd8c69d450a4e279a0dbbdb5e7d917e54405e84","mac":"eb941f9a9317d7b27f7bda11988b6478a87bed80d644ccf6b09131e4a488bcd4","mode":"AES256"}}]},"id":10}"#.utf8),
        statusCode: 200,
        responseHeaders: mustDecodeJSON(#"{"Content-Length":"722","Vary":"Origin","Date":"Sun, 17 Oct 2021 10:57:32 GMT","Server":"nginx/1.19.9","Content-Type":"application/json"}"#) as! [String: String]
    ),

    Stub(
        requestMatcher: stubMatcherWithBody(
            host: "teal-15-2.torusnode.com",
            scheme: "https",
            path: "/jrpc",
            method: "POST",
            requestHeaders: mustDecodeJSON(#"{"Accept":"application/json","Content-Type":"application/json"}"#) as! [String: String],
            body: mustDecodeJSON(#"{"params":{"encrypted":"yes","item":[{"verifieridentifier":"torus-direct-mock-ios","nodesignatures":[{"signature":"f94f88b5a2fff06463fe0cb4569a652a11f351061dcd5b15e466274e374eb2992632153bda0c017d9c83916b82f1daa3ee5ac9990201d73a18915224a828b6a41b","nodepubx":"1363aad8868cacd7f8946c590325cd463106fb3731f08811ab4302d2deae35c3","data":"mug00\u001cf9a9e61d68072c950e5dc8baf824b810d52073e9e3748e35f9a534502bac8a5b\u001c3b695585f9c5ac4a4f036757c8873d01f51b68d5e8f0274e2dc4ebbc7daa7025\u001c03b18e36aa6c864091cd7d6536d30a3808c772f18479d753e12847266144c10e\u001ctorus-direct-mock-ios\u001c1634468252","nodepuby":"d77eebe5cdf466b475ec892d5b4cffbe0c1670525debbd97eee6dae2f87a7cbe"},{"nodepubx":"7c8cc521c48690f016bea593f67f88ad24f447dd6c31bbab541e59e207bf029d","nodepuby":"b359f0a82608db2e06b953b36d0c9a473a00458117ca32a5b0f4563a7d539636","data":"mug00\u001cf9a9e61d68072c950e5dc8baf824b810d52073e9e3748e35f9a534502bac8a5b\u001c3b695585f9c5ac4a4f036757c8873d01f51b68d5e8f0274e2dc4ebbc7daa7025\u001c03b18e36aa6c864091cd7d6536d30a3808c772f18479d753e12847266144c10e\u001ctorus-direct-mock-ios\u001c1634468252","signature":"ee5b3560bc5b394326ddb784970eb27c995b77ceac9ce04ddffe72a52542dffd7b90b30c50b69481b43f04a0373b632798bac8fcdf8d695ead606200e0a24fc41c"},{"signature":"739487dab15bc238d32db83faf7b0aeb57f6863ac079aa331605eee9e076567c5cfa588978128af9d2c160d92a30197ccec8ab8c24ea68a3ac540a2534f65e261c","nodepubx":"8a86543ca17df5687719e2549caa024cf17fe0361e119e741eaee668f8dd0a6f","data":"mug00\u001cf9a9e61d68072c950e5dc8baf824b810d52073e9e3748e35f9a534502bac8a5b\u001c3b695585f9c5ac4a4f036757c8873d01f51b68d5e8f0274e2dc4ebbc7daa7025\u001c03b18e36aa6c864091cd7d6536d30a3808c772f18479d753e12847266144c10e\u001ctorus-direct-mock-ios\u001c1634468252","nodepuby":"9cdb254ff915a76950d6d13d78ef054d5d0dc34e2908c00bb009a6e4da701891"},{"data":"mug00\u001cf9a9e61d68072c950e5dc8baf824b810d52073e9e3748e35f9a534502bac8a5b\u001c3b695585f9c5ac4a4f036757c8873d01f51b68d5e8f0274e2dc4ebbc7daa7025\u001c03b18e36aa6c864091cd7d6536d30a3808c772f18479d753e12847266144c10e\u001ctorus-direct-mock-ios\u001c1634468252","signature":"d24ccf58546df41bc8506b467e017ec64d941feb442a02001bea1c014dbe4d6b01317473884284d038ea116e6040ab25dad9901ee94d41dd33674cd105bc32151b","nodepuby":"f63d40df480dacf68922004ed36dbab9e2969181b047730a5ce0797fb6958249","nodepubx":"25a98d9ae006aed1d77e81d58be8f67193d13d01a9888e2923841894f4b0bf9c"}],"verifier_id":"michael@tor.us","idtoken":"eyJhbGciOiJSUzI1NiIsImtpZCI6ImFkZDhjMGVlNjIzOTU0NGFmNTNmOTM3MTJhNTdiMmUyNmY5NDMzNTIiLCJ0eXAiOiJKV1QifQ.eyJpc3MiOiJodHRwczovL2FjY291bnRzLmdvb2dsZS5jb20iLCJhenAiOiI2MzYxOTk0NjUyNDItZmQ3dWp0b3JwdnZ1ZHRzbDN1M2V2OTBuaWplY3RmcW0uYXBwcy5nb29nbGV1c2VyY29udGVudC5jb20iLCJhdWQiOiI2MzYxOTk0NjUyNDItZmQ3dWp0b3JwdnZ1ZHRzbDN1M2V2OTBuaWplY3RmcW0uYXBwcy5nb29nbGV1c2VyY29udGVudC5jb20iLCJzdWIiOiIxMDkxMTE5NTM4NTYwMzE3OTk2MzkiLCJoZCI6InRvci51cyIsImVtYWlsIjoibWljaGFlbEB0b3IudXMiLCJlbWFpbF92ZXJpZmllZCI6dHJ1ZSwiYXRfaGFzaCI6InRUNDhSck1vdGFFbi1UN3dzc2U3QnciLCJub25jZSI6InZSU2tPZWwyQTkiLCJuYW1lIjoiTWljaGFlbCBMZWUiLCJwaWN0dXJlIjoiaHR0cHM6Ly9saDMuZ29vZ2xldXNlcmNvbnRlbnQuY29tL2EvQUFUWEFKd3NCYjk4Z1NZalZObEJCQWhYSmp2cU5PdzJHRFNlVGYwSTZTSmg9czk2LWMiLCJnaXZlbl9uYW1lIjoiTWljaGFlbCIsImZhbWlseV9uYW1lIjoiTGVlIiwibG9jYWxlIjoiZW4iLCJpYXQiOjE2MzQ0NjgyNDksImV4cCI6MTYzNDQ3MTg0OX0.XGu1tm_OqlSrc5BMDMzOrlhxLZo1YnpCUT0_j2U1mQt86nJzf_Hp85JfapZj2QeeUz91H6-Ei8FR1i4ICEfjMcoZOW1Azc89qUNfUgWeyjqZ7wCHSsbHAwabE74RFAS9YAja8_ynUvCARfDEtoqcreNgmbw3ZntzAqpuuNBXYfbr87kMvu_wZ7fWjLKM91CvuXytQBwtieTyjAFnTXmEL60Pdu-JSQfHCbS5H39ZHlnYxEO6qztIjvbnQokhjHDGc4PMCx0wfzrEet1ojNOCnbfmaYE5NQudquzQNZtqZfn8f4B-sQhECElnOXagHlafWO5RayS0dCb1mTfr8orcCA"}]},"id":10,"method":"ShareRequest","jsonrpc":"2.0"}"#)
        ),
        responseBody: Data(#"{"jsonrpc":"2.0","result":{"keys":[{"Index":"1c724","PublicKey":{"X":"22d225892d5d149c0486bfb358b143568d1a951c39d5ada061a48c06c48afe39","Y":"fcd9074bff4b5097489b79f951146d66bbcd05dc6acf68b8d0afc271fb73cf64"},"Threshold":1,"Verifiers":{"torus-direct-mock-ios":["michael@tor.us"]},"Share":"OTNhMzBjODY1YjM4OTNiNWQxOWQ2MmNmZmY1YjUzNTE1NzViZjZiMmM3ZmM0YWFmZTRiYzY0ZjA3YjkzNjU0MzczYzhjNmIyYjQ0ZjIzNTIyZWUwOGRmZWVjNzFlMjVk","Metadata":{"iv":"6e8150c48e9eaae7f03d71fe339e8ddf","ephemPublicKey":"048a363e0572bb294e979e5588488d3f702ea99df104b1b9a82e52505d85983d6ea11061a70a9bd99b2e77a0dc5e816eb1080618f96865ef318129711cd9f6634c","mac":"94d7c5a01d2a01379abb3a3a7c604910f8d58ac0f75c427392ea7c8c8085509c","mode":"AES256"}}]},"id":10}"#.utf8),
        statusCode: 200,
        responseHeaders: mustDecodeJSON(#"{"Vary":"Origin","Server":"nginx/1.19.9","Content-Length":"722","Content-Type":"application/json","Date":"Sun, 17 Oct 2021 10:57:32 GMT"}"#) as! [String: String]
    ),

    Stub(
        requestMatcher: stubMatcherWithBody(
            host: "teal-15-4.torusnode.com",
            scheme: "https",
            path: "/jrpc",
            method: "POST",
            requestHeaders: mustDecodeJSON(#"{"Accept":"application/json","Content-Type":"application/json"}"#) as! [String: String],
            body: mustDecodeJSON(#"{"params":{"encrypted":"yes","item":[{"verifieridentifier":"torus-direct-mock-ios","nodesignatures":[{"signature":"f94f88b5a2fff06463fe0cb4569a652a11f351061dcd5b15e466274e374eb2992632153bda0c017d9c83916b82f1daa3ee5ac9990201d73a18915224a828b6a41b","nodepubx":"1363aad8868cacd7f8946c590325cd463106fb3731f08811ab4302d2deae35c3","data":"mug00\u001cf9a9e61d68072c950e5dc8baf824b810d52073e9e3748e35f9a534502bac8a5b\u001c3b695585f9c5ac4a4f036757c8873d01f51b68d5e8f0274e2dc4ebbc7daa7025\u001c03b18e36aa6c864091cd7d6536d30a3808c772f18479d753e12847266144c10e\u001ctorus-direct-mock-ios\u001c1634468252","nodepuby":"d77eebe5cdf466b475ec892d5b4cffbe0c1670525debbd97eee6dae2f87a7cbe"},{"nodepubx":"7c8cc521c48690f016bea593f67f88ad24f447dd6c31bbab541e59e207bf029d","nodepuby":"b359f0a82608db2e06b953b36d0c9a473a00458117ca32a5b0f4563a7d539636","data":"mug00\u001cf9a9e61d68072c950e5dc8baf824b810d52073e9e3748e35f9a534502bac8a5b\u001c3b695585f9c5ac4a4f036757c8873d01f51b68d5e8f0274e2dc4ebbc7daa7025\u001c03b18e36aa6c864091cd7d6536d30a3808c772f18479d753e12847266144c10e\u001ctorus-direct-mock-ios\u001c1634468252","signature":"ee5b3560bc5b394326ddb784970eb27c995b77ceac9ce04ddffe72a52542dffd7b90b30c50b69481b43f04a0373b632798bac8fcdf8d695ead606200e0a24fc41c"},{"signature":"739487dab15bc238d32db83faf7b0aeb57f6863ac079aa331605eee9e076567c5cfa588978128af9d2c160d92a30197ccec8ab8c24ea68a3ac540a2534f65e261c","nodepubx":"8a86543ca17df5687719e2549caa024cf17fe0361e119e741eaee668f8dd0a6f","data":"mug00\u001cf9a9e61d68072c950e5dc8baf824b810d52073e9e3748e35f9a534502bac8a5b\u001c3b695585f9c5ac4a4f036757c8873d01f51b68d5e8f0274e2dc4ebbc7daa7025\u001c03b18e36aa6c864091cd7d6536d30a3808c772f18479d753e12847266144c10e\u001ctorus-direct-mock-ios\u001c1634468252","nodepuby":"9cdb254ff915a76950d6d13d78ef054d5d0dc34e2908c00bb009a6e4da701891"},{"data":"mug00\u001cf9a9e61d68072c950e5dc8baf824b810d52073e9e3748e35f9a534502bac8a5b\u001c3b695585f9c5ac4a4f036757c8873d01f51b68d5e8f0274e2dc4ebbc7daa7025\u001c03b18e36aa6c864091cd7d6536d30a3808c772f18479d753e12847266144c10e\u001ctorus-direct-mock-ios\u001c1634468252","signature":"d24ccf58546df41bc8506b467e017ec64d941feb442a02001bea1c014dbe4d6b01317473884284d038ea116e6040ab25dad9901ee94d41dd33674cd105bc32151b","nodepuby":"f63d40df480dacf68922004ed36dbab9e2969181b047730a5ce0797fb6958249","nodepubx":"25a98d9ae006aed1d77e81d58be8f67193d13d01a9888e2923841894f4b0bf9c"}],"verifier_id":"michael@tor.us","idtoken":"eyJhbGciOiJSUzI1NiIsImtpZCI6ImFkZDhjMGVlNjIzOTU0NGFmNTNmOTM3MTJhNTdiMmUyNmY5NDMzNTIiLCJ0eXAiOiJKV1QifQ.eyJpc3MiOiJodHRwczovL2FjY291bnRzLmdvb2dsZS5jb20iLCJhenAiOiI2MzYxOTk0NjUyNDItZmQ3dWp0b3JwdnZ1ZHRzbDN1M2V2OTBuaWplY3RmcW0uYXBwcy5nb29nbGV1c2VyY29udGVudC5jb20iLCJhdWQiOiI2MzYxOTk0NjUyNDItZmQ3dWp0b3JwdnZ1ZHRzbDN1M2V2OTBuaWplY3RmcW0uYXBwcy5nb29nbGV1c2VyY29udGVudC5jb20iLCJzdWIiOiIxMDkxMTE5NTM4NTYwMzE3OTk2MzkiLCJoZCI6InRvci51cyIsImVtYWlsIjoibWljaGFlbEB0b3IudXMiLCJlbWFpbF92ZXJpZmllZCI6dHJ1ZSwiYXRfaGFzaCI6InRUNDhSck1vdGFFbi1UN3dzc2U3QnciLCJub25jZSI6InZSU2tPZWwyQTkiLCJuYW1lIjoiTWljaGFlbCBMZWUiLCJwaWN0dXJlIjoiaHR0cHM6Ly9saDMuZ29vZ2xldXNlcmNvbnRlbnQuY29tL2EvQUFUWEFKd3NCYjk4Z1NZalZObEJCQWhYSmp2cU5PdzJHRFNlVGYwSTZTSmg9czk2LWMiLCJnaXZlbl9uYW1lIjoiTWljaGFlbCIsImZhbWlseV9uYW1lIjoiTGVlIiwibG9jYWxlIjoiZW4iLCJpYXQiOjE2MzQ0NjgyNDksImV4cCI6MTYzNDQ3MTg0OX0.XGu1tm_OqlSrc5BMDMzOrlhxLZo1YnpCUT0_j2U1mQt86nJzf_Hp85JfapZj2QeeUz91H6-Ei8FR1i4ICEfjMcoZOW1Azc89qUNfUgWeyjqZ7wCHSsbHAwabE74RFAS9YAja8_ynUvCARfDEtoqcreNgmbw3ZntzAqpuuNBXYfbr87kMvu_wZ7fWjLKM91CvuXytQBwtieTyjAFnTXmEL60Pdu-JSQfHCbS5H39ZHlnYxEO6qztIjvbnQokhjHDGc4PMCx0wfzrEet1ojNOCnbfmaYE5NQudquzQNZtqZfn8f4B-sQhECElnOXagHlafWO5RayS0dCb1mTfr8orcCA"}]},"id":10,"method":"ShareRequest","jsonrpc":"2.0"}"#)
        ),
        responseBody: Data(#"{"jsonrpc":"2.0","result":{"keys":[{"Index":"1c724","PublicKey":{"X":"22d225892d5d149c0486bfb358b143568d1a951c39d5ada061a48c06c48afe39","Y":"fcd9074bff4b5097489b79f951146d66bbcd05dc6acf68b8d0afc271fb73cf64"},"Threshold":1,"Verifiers":{"torus-direct-mock-ios":["michael@tor.us"]},"Share":"M2U2OGMxYzg0ODFhMDAxNTFkOWE1MTMyMmZjNjlkOWQ0MWUzZjgzZDQ0NGJlNmQ1YzdlMDEwNzliZTRhYjg4OTdmM2Y3YWRiNjcwZDZhMTA5MDk4NjE2OGI2OTBlZWM2","Metadata":{"iv":"29a6a7bb27cd3a9a13cfb47818e894a0","ephemPublicKey":"0489299b0ccc867e2596e2069dce3c129e163f9e8c47c51c2dd2ea5aa56af88b4cfa4cfab34ece86512dc0995fcbab1fe9206609cafa648a66bc35d95c1795dd41","mac":"541759eb560a77517057c452b11113630e2ac32de7ba2addab8643ff52a19f59","mode":"AES256"}}]},"id":10}"#.utf8),
        statusCode: 200,
        responseHeaders: mustDecodeJSON(#"{"Date":"Sun, 17 Oct 2021 10:57:33 GMT","Content-Type":"application/json","Content-Length":"722","Vary":"Origin","Server":"nginx/1.19.9"}"#) as! [String: String]
    ),

    Stub(
        requestMatcher: stubMatcherWithBody(
            host: "metadata.tor.us",
            scheme: "https",
            path: "/get",
            method: "POST",
            requestHeaders: mustDecodeJSON(#"{"Accept":"application/json","Content-Type":"application/json"}"#) as! [String: String],
            body: mustDecodeJSON(#"{"pub_key_X":"22d225892d5d149c0486bfb358b143568d1a951c39d5ada061a48c06c48afe39","pub_key_Y":"fcd9074bff4b5097489b79f951146d66bbcd05dc6acf68b8d0afc271fb73cf64"}"#)
        ),
        responseBody: Data(#"{"message":""}"#.utf8),
        statusCode: 200,
        responseHeaders: mustDecodeJSON(#"{"Content-Type":"application/json; charset=utf-8","Etag":"W/\"e-JWOqSwGs6lhRJiUZe/mVb6Mua74\"","x-xss-protection":"0","x-content-type-options":"nosniff","Vary":"Origin, Accept-Encoding","x-frame-options":"SAMEORIGIN","referrer-policy":"no-referrer","content-security-policy":"default-src 'self';base-uri 'self';block-all-mixed-content;font-src 'self' https: data:;frame-ancestors 'self';img-src 'self' data:;object-src 'none';script-src 'self';script-src-attr 'none';style-src 'self' https: 'unsafe-inline';upgrade-insecure-requests","Date":"Sun, 17 Oct 2021 10:57:33 GMT","x-dns-prefetch-control":"off","x-permitted-cross-domain-policies":"none","Strict-Transport-Security":"max-age=15552000; includeSubDomains","x-download-options":"noopen","Content-Length":"14","expect-ct":"max-age=0"}"#) as! [String: String]
    ),
]

fileprivate let httpBodyKey = "StubURLProtocolHTTPBody"

fileprivate struct Stub {
    let requestMatcher: (URLRequest) -> Bool
    let responseBody: Data?
    let statusCode: Int
    let responseHeaders: [String: String]
}

public class StubURLProtocol: URLProtocol {
    private static let terminateUnknownRequest = true

    private static let stubs = injectedStubs

    private static let urls = injectedURLs

    private class func matchStub(req: URLRequest) -> Stub? {
        var inputReq: URLRequest
        if let httpBodyData = httpBodyStreamToData(stream: req.httpBodyStream) {
            let mutableReq = (req as NSURLRequest).mutableCopy() as! NSMutableURLRequest
            setProperty(httpBodyData, forKey: httpBodyKey, in: mutableReq)
            inputReq = mutableReq as URLRequest
        } else {
            inputReq = req
        }
        for stub in stubs {
            if stub.requestMatcher(inputReq) {
                return stub
            }
        }
        return nil
    }

    override public class func canInit(with request: URLRequest) -> Bool {
        var cleanURL: URL? {
            var comp = URLComponents()
            comp.scheme = request.url?.scheme
            comp.host = request.url?.host
            comp.path = request.url?.path ?? "/"
            return comp.url
        }
        if urls.contains(cleanURL) {
            return true
        }
        return terminateUnknownRequest
    }

    override public class func canonicalRequest(for request: URLRequest) -> URLRequest {
        return request
    }

    override public func startLoading() {
        guard let url = request.url else {
            fatalError("Request has no URL")
        }
        var cleanURL: URL? {
            var comp = URLComponents()
            comp.scheme = url.scheme
            comp.host = url.host
            comp.path = url.path
            return comp.url
        }
        if !StubURLProtocol.urls.contains(cleanURL) {
            fatalError("URL not mocked, inconsistent injectedURLs: \(url.absoluteString)")
        }
        if let stub = StubURLProtocol.matchStub(req: request) {
            let res = HTTPURLResponse(url: url, statusCode: stub.statusCode, httpVersion: nil, headerFields: stub.responseHeaders)!
            client?.urlProtocol(self, didReceive: res, cacheStoragePolicy: .notAllowed)
            if let d = stub.responseBody {
                client?.urlProtocol(self, didLoad: d)
            }
        } else {
            fatalError("URL not mocked: \(url.absoluteString)")
        }
        client?.urlProtocolDidFinishLoading(self)
    }

    override public func stopLoading() {
    }
}
