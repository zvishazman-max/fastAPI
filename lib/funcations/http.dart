// import 'dart:convert' show jsonDecode, utf8, json;
// import 'package:http/http.dart' as http;
//
// const String url =  "algo-test-449716.ew.r.appspot.com";
// final String clientId = "1d48a1e3e8d246aabbfe0b8063482238";
// final String redirectUri = "https://hitster-game.firebaseapp.com/";
//
// Future<Map<String,dynamic>> post(String to, {Map<String,String>? headers, Map<String,String>? headerData, Object? body,Map<String, dynamic>? queryParameters,List<int>? statusCodes, List<int>? expectStatusCodes, bool? typeJson=true,bool? returnAsConvert=true,Duration? timeout,bool? withLoading=true, Color? loadingColor, BuildContext? context}) async {
//   Map<String,dynamic> map = {'statusCode': 500};
//   try {
//     //if (withLoading??true) showLoadingOverlay(circularColor: loadingColor, timeout: timeout??const Duration(seconds: 15));
//     await http.post(Uri.https(url,to,queryParameters), headers: headers??getHeaders(auth: pageInfo['access_token'], typeJson: typeJson??true, data: headerData),body: json.encode(body)).then((response) {
//       //if (withLoading??true) closeLoadingOverlay();
//       map['statusCode'] = response.statusCode;
//       if ((statusCodes??[200]).contains(response.statusCode)) {
//         map['headers'] = response.headers;
//         map['body'] = (returnAsConvert ?? true) ? jsonDecode(utf8.decode(response.bodyBytes)) : response.bodyBytes;
//       }
//       else {
//        // if (!((expectStatusCodes??[]).contains(response.statusCode))) showSnackBar(context: context, text: response.statusCode==422 ? '${((returnAsConvert??true)?jsonDecode(utf8.decode(response.bodyBytes)):response.bodyBytes)['detail']}' : '${getWord('${pageInfo['language']}', 'something')} ${getWord('${pageInfo['language']}', 'wentWrong')}');
//       }
//     }).timeout(timeout??const Duration(seconds: 15), onTimeout: () {return null;}); //showSnackBar(context: context, text: checkLanguageRtl()?'תקלה, יש לנסות שוב':'Error, try again');
//   } catch (e) {
//     //if (withLoading??true) closeLoadingOverlay();
//     print('error post $to | $e');
//   }
//   return map;
// }
