import 'package:objectbox/objectbox.dart';
import 'package:fittracker/dbModels/routine_entry_model.dart';
import 'package:fittracker/dbModels/session_item_model.dart';

@Entity()
class SetItem {
  int id = 0;
  double metricValue = 0;
  int countValue = 0;

  SetItem({
    required this.metricValue,
    required this.countValue
  });
}