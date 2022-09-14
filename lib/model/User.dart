import 'package:get/get.dart';
class AppUser {
  String id;
  String? fullname;
  String? phone;
  double? rating;
  String? birthdate;
  String? gender;
  String? car;
  int? totalRides;
  String? profileImage;
  AppUser(this.id,this.fullname,this.phone,this.rating,this.birthdate,this.gender, this.car,this.totalRides,this.profileImage);
  AppUser.name(this.id,this.fullname,this.phone,this.rating,this.birthdate, this.gender,this.totalRides,this.profileImage);
  AppUser.empty(this.id);
}