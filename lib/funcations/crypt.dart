import 'package:jaguar_jwt/jaguar_jwt.dart';

Map<String,dynamic> decodeWithJwt(String token, String key) {
  try {
    //print("decodeWithJwt:\ntoken: |$token|\nkey: |$key|");
    final JwtClaim jwtClaim = verifyJwtHS256Signature(token, key);
    //print('$key: ${jwtClaim.expiry}');
    return jwtClaim.toJson();
  } catch (e) {print("error decodeWithJwt: $e\n$JwtClaim");}
  return {};
}

Future<String> encodeWithJwt(Map<String,dynamic>? otherClaims, String key, Duration? expireIn, {bool? defaultIatExp=false}) async {
  print("expiry: $expireIn\notherClaims: $otherClaims");
  final JwtClaim claimSet = JwtClaim(otherClaims: otherClaims, expiry: expireIn!=null? DateTime.now().toUtc().add(expireIn) : null, maxAge: expireIn, defaultIatExp: defaultIatExp??false);
  final String token = issueJwtHS256(claimSet, key);
  print("token: $token");
  return token;
}
