import 'package:objectbox/objectbox.dart';
import 'package:fittracker/util/typedef.dart';

@Entity()
class WorkoutEntry {
  int id = 0;
  String metric = MetricType.kg.name;
  String type = WorkoutType.other.name;
  List<String> partList = [];
  String caption = "";
  String description = "";
  int prevSessionId = -1;
  bool visible = true;

  WorkoutEntry(
  {
    required this.metric,
    required this.type,
    required this.partList,
    required this.caption
  });
}