import 'dart:io';

class Connection {
  static Future<bool> checkIfConnected() async {
    try {
     List<InternetAddress> res = await InternetAddress.lookup("www.google.com");
     return res.isNotEmpty && res.first.rawAddress.isNotEmpty == true ? true : false;
    } on SocketException catch(_) {}
    return false;
  }
}
