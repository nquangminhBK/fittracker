import 'package:objectbox/objectbox.dart';
import 'package:fittracker/dbModels/set_item_model.dart';

@Entity()
class SessionItem {
  int id = 0;
  int time = 0;
  String metric = "";
  int workoutId = 0;
  final sets = ToMany<SetItem>();
}