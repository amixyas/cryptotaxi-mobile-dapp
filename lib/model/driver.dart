import 'dart:core';

class Driver
{
  String? placeFormattedAddress;
  String? name;
  int? age;
  String? id;
  double? latitude;
  double? longitude;
  String? phone;
  double? rating;
  String? token;
  String? profileImage;
  String? car;
  double? distance;
  String? totalRides;
  List<String>? imgurl;
  Driver({this.age,this.distance,this.rating,this.imgurl,this.token,this.placeFormattedAddress,this.phone,this.name,this.id,this.latitude,this.longitude,this.profileImage,this.car,this.totalRides});


  @override
  bool operator == (Object other) {
    // TODO: implement ==
    return super == other;
  }
}