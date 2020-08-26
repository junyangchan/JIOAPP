import 'package:geolocator/geolocator.dart';

class Geolocation{

  static getCurrentLocation() async{
    final Geolocator _geoLocator = Geolocator()..forceAndroidLocationManager = true;
    Position position = await _geoLocator
        .getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    return position;
  }

  static Future<double> distanceFromHost(double _hostLat,double _hostLong,double _userLat,double _userLong) async{
    final Geolocator _geoLocator = Geolocator()..forceAndroidLocationManager;
    double distanceInMeters = await _geoLocator.distanceBetween(_hostLat, _hostLong, _userLat, _userLong);
    return distanceInMeters;
  }
}