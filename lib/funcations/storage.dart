import 'dart:html' show window,Storage;

import 'package:hitster/functions/crypt.dart' show decodeWithJwt, encodeWithJwt;

final Storage localStorage = window.localStorage;

Future<void> writeToStorage(String key, {String? value, Map<String,dynamic>? valueMap, Duration? expireIn}) async => localStorage['hitster$key']=(await encodeWithJwt((valueMap??{key: value}), 'storageKey\$%*&\$^*/\$', expireIn));

Future<String> readKeyFromStorageAndDecode(String key) async {
 if (checkStorageKey(key)) return (decodeWithJwt(await readKeyFromStorage(key), 'storageK3y0@#das\$'))[key];
 return "null";
}

Future<Map<String, dynamic>> readKeyFromStorageAndDecodeMap(String key) async {
 if (checkStorageKey(key)) return (decodeWithJwt(await readKeyFromStorage(key), 'storageK3y0@#das\$'));
 return {};
}

Future<String> readKeyFromStorage(String key) async => "${localStorage['hitster$key']}";

Future<String> readAndDeleteKeyFromStorage(String key) async {
 String str = await readKeyFromStorageAndDecode(key);
 localStorage.remove(key);
 return str;
}

bool checkStorageKey(String key) => localStorage.containsKey('hitster$key');

//bool isStorageEmpty() => localStorage.isEmpty;

void deleteKeyFromStorage(String key) => localStorage.remove('hitster$key');

void deleteAllFromStorage() => localStorage.clear();

void deleteWhereFromStorage() => localStorage.removeWhere((key, value) => (key!='language'));

void deleteWhereKeyStorage(List<String> list) => localStorage.removeWhere((key, value) => list.contains(key));

void deleteWhereValueStorage(List<String> list) => localStorage.removeWhere((key, value) => list.contains(value));

Future<void> changeExpiry({required Duration newExpiry}) async {
 localStorage.forEach((key, value) async {
  if (key.contains('hitster')) {
   print('change: $key');
   final Map<String, dynamic> data = await readKeyFromStorageAndDecodeMap(key.replaceAll('hitster', ''));
   data.remove('exp');data.remove('iat');
   print('put\n$data\nwith new code');
   localStorage[key]=(await encodeWithJwt(data ,'storageKey\$%*&\$^*/\$', newExpiry));
  }
 });
}
