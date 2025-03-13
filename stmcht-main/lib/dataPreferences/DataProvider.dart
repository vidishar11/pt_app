import 'package:flutter/cupertino.dart';
import 'package:get_secure_storage/get_secure_storage.dart';

class DataProvider {
  final box = GetSecureStorage(password: 'strongpassword');

 static final String bt_c = "bt_c";
  static final String model = "model";
  static final String mobie_id = "mobie_id";
  static final String speed = "speed";
  static final String altitude = "altitude";
  static  final String fixType = "fixType";
  static  final String longitude = "longitude";
  static  final String latitude = "latitude";
  static  final String readMTM = "readMTM";
  static final String sendMOM = "sendMOM";
  static final String frimwareRevision = "frimwareRevision";
  static final String satstate = "satstate";
  static final String contactsList = "contactslist";
  static final String batterylevel = "batterylevel";

  Future<bool> setData(String key,dynamic request,) {
    return box
        .write(key, request)
        .then((value) => true)
        .catchError((error) => false);
  }

  Future<String?> getData(String key) async {

  return   box.read(key);

  }



}
