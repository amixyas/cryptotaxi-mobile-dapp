import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'User.dart';

class Ride {
  late String id;
  AppUser? client;
  AppUser? driver;
  LatLng? pickup;
  LatLng? dropOff;
  String? createdAt;
  double? price;
  String? pickupAddress;
  String? dropOffAddress;
  Ride.unnamed();
  Ride(
      this.id,
      this.client,
      this.driver,
      this.pickup,
      this.dropOff,
      this.createdAt,
      this.price,
      this.pickupAddress,
      this.dropOffAddress);

  Ride.name(
      this.id,
      this.client,
      this.driver,
      this.pickup,
      this.dropOff,
      this.createdAt,
      this.price,
      this.pickupAddress,
      this.dropOffAddress);
}
