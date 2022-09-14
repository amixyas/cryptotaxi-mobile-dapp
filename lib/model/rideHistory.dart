import 'driver.dart';

class History {
  late String id;
  late String duration;
  late DateTime time;
  String? pickUpAddress;
  String? dropOffAddress;
  Driver? driver;
  String? cost;
  DateTime? neTime;
  History(this.id,this.duration,this.time,this.pickUpAddress,this.dropOffAddress,this.driver,this.cost,this.neTime);
}