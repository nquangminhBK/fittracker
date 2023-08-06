import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fittracker/dbModels/workout_entry_model.dart';
import 'package:fittracker/util/objectbox.dart';
import 'package:fittracker/util/typedef.dart';
import 'package:fittracker/widgets/UIComponents.dart';
import 'package:fittracker/util/StringTool.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class AddWorkoutEntryWidget extends StatefulWidget {
  late ObjectBox objectbox;
  late bool edit;
  late int id;
  AddWorkoutEntryWidget({Key? key, required this.objectbox, required this.edit, required this.id}) : super(key: key);
  @override
  State createState() => _AddWorkoutEntryState();
}

class _AddWorkoutEntryState extends State<AddWorkoutEntryWidget> {
  late WorkoutEntry? newEntry;

  late String type, metric, caption;
  final workoutNameController = TextEditingController();
  final descriptionController = TextEditingController();
  List<String> partList = [];
  String locale = "";

  @override
  void initState() {
    super.initState();
    String? temp = widget.objectbox.getPref("locale");
    locale = temp != null ? temp : 'en';

    if(widget.edit)
      {
        newEntry = widget.objectbox.workoutBox.get(widget.id);
        partList = newEntry!.partList;
        type = newEntry!.type;
        metric = newEntry!.metric;
        workoutNameController.text = newEntry!.caption;
        descriptionController.text = newEntry!.description;
      }
    else{
      partList = [];
      type = WorkoutType.other.name;
      metric = MetricType.kg.name;
      caption = "";
      newEntry = new WorkoutEntry(metric: metric, type: type, partList: partList, caption: caption);
    }
  }


  List<Widget> selectPartList(setDialogState)
  {
    List<Widget> tagList = [];

    for(int i = 0; i < PartType.values.length; i++)
    {
      PartType p = PartType.values[i];
      tagList.add(
          tag(p.toLanguageString(locale),
                  (){
                if(partList.contains(p.name))
                  partList.remove(p.name);
                else
                  partList.add(p.name);
                setState(() {});
                setDialogState((){});
              } ,
              partList.contains(p.name) ? Colors.deepPurple : Colors.black12)
      );
    }

    return tagList;
  }

  // List of Tags in partList
  List<Widget> selectedTagList()
  {
    List<Widget> tagList = [];

    for(int i = 0; i < partList.length; i++)
      tagList.add(tag(PartType.values.firstWhere((element) => element.name == partList[i]).toLanguageString(locale), (){_openTagPopup(context);}, Colors.deepPurpleAccent));

    if(partList.length == 0)
      tagList.add(tag(" + " + AppLocalizations.of(context)!.add_part + "  ", (){_openTagPopup(context);}, Color.fromRGBO(230, 230, 230, 0.8)));
    return tagList;
  }

  void _openTagPopup(BuildContext buildContext)
  {
    showDialog(
        context: context,
        builder: (BuildContext dialogContext) {
          return StatefulBuilder(
              builder: (context, setState) {
                return AlertDialog(
                  scrollable: false,
                  title: Text(AppLocalizations.of(buildContext)!.choose_parts),
                  content: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Wrap(
                        alignment: WrapAlignment.start,
                        children: selectPartList(setState)
                    ),
                  ),
                  actions: [
                    ElevatedButton(
                        child: Text(AppLocalizations.of(buildContext)!.close),
                        onPressed: () {
                          Navigator.pop(dialogContext);
                        }
                    )
                  ],
                );
              }
          );
        }
    );
  }

  void saveWorkout()
  {
    if(workoutNameController.text.isEmpty) {
      final snackBar = SnackBar(
        content: Text(AppLocalizations.of(context)!.workout_snackbar_msg),
      );

      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      return;
    }

    newEntry!.caption = workoutNameController.text;
    newEntry!.type = type;
    newEntry!.partList = partList;
    newEntry!.metric = metric;
    newEntry!.description = descriptionController.text;

    if(!widget.edit)
    {
      for(WorkoutEntry entry in widget.objectbox.workoutList)
        if(entry.caption == newEntry!.caption &&
            entry.type == newEntry!.type &&
            listEquals(entry.partList, newEntry!.partList) &&
            entry.metric == newEntry!.metric &&
            entry.description == newEntry!.description &&
            entry.visible == newEntry!.visible
        )
          {
            final snackBar = SnackBar(
              content: Text(AppLocalizations.of(context)!.workout_identical_exists),
            );
            ScaffoldMessenger.of(context).showSnackBar(snackBar);
            return;
          }
    }

    widget.objectbox.workoutBox.put(newEntry!);
    widget.objectbox.workoutList = widget.objectbox.workoutBox.getAll().where((element) => element.visible).toList();
    Navigator.pop(context, true);
  }

  List<Widget> _buildActions() {
    return <Widget>[
      IconButton(
        icon: const Icon(Icons.save),
        onPressed: (){
          saveWorkout();
        },
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () async{
          Navigator.pop(context, false);
          return false;
        },
        child: new GestureDetector(
            onTap: () {
              FocusScope.of(context).unfocus();
            },
            child: new Scaffold(
                appBar: AppBar(
                  title: Text(widget.edit? AppLocalizations.of(context)!.workout_edit_workout : AppLocalizations.of(context)!.workout_add_workout),
                  actions: _buildActions(),
                  backgroundColor: Colors.deepPurpleAccent,
                ),
                body: Builder(
                    builder: (context) =>
                        SingleChildScrollView(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                // System Values
                                Container(
                                    padding: EdgeInsets.fromLTRB(10, 10, 0, 0),
                                    child: Text(AppLocalizations.of(context)!.workout_name,
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.grey
                                      ),
                                    )
                                ),
                                Card(
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
                                    margin: EdgeInsets.all(8.0),
                                    child: Column(
                                      children: <Widget>[
                                        ListTile(
                                            title: new Row(
                                              children: <Widget>[
                                                new Flexible(
                                                  child: new TextField(
                                                    controller: workoutNameController,
                                                    decoration: InputDecoration(
                                                        border:InputBorder.none,
                                                        hintText: AppLocalizations.of(context)!.enter_name,
                                                      ),
                                                    )
                                                )
                                              ],
                                            )
                                        ),
                                        ]
                                    )
                                ),
                                Container(
                                    padding: EdgeInsets.fromLTRB(10, 10, 0, 10),
                                    child: Text(AppLocalizations.of(context)!.workout_part,
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.grey
                                      ),
                                    )
                                ),
                                Container(
                                  margin: EdgeInsets.fromLTRB(10, 0, 10, 0),
                                  child: Wrap(
                                      alignment: WrapAlignment.start,
                                      children: selectedTagList()
                                  ),
                                ),
                                Container(
                                    padding: EdgeInsets.fromLTRB(10, 10, 0, 0),
                                    child: Text(AppLocalizations.of(context)!.workout_details,
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.grey
                                      ),
                                    )
                                ),
                                Card(
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
                                    margin: EdgeInsets.fromLTRB(8, 8, 8, 4),
                                    child: Column(
                                      children: <Widget>[
                                        ListTile(
                                            title: new Row(
                                              children: <Widget>[
                                                Text(AppLocalizations.of(context)!.type),
                                                Spacer(),
                                                DropdownButton<String>(
                                                  value: type,
                                                  iconSize: 24,
                                                  elevation: 16,
                                                  onChanged: (value){
                                                    setState(() {type = value!;});
                                                  },
                                                  underline: Container(
                                                    height: 2,
                                                  ),
                                                  selectedItemBuilder: (BuildContext context) {
                                                    return WorkoutType.values.map<Widget>((WorkoutType value) {
                                                      return Container(
                                                          alignment: Alignment.centerRight,
                                                          width: 100, // TODO: Find Proper Width
                                                          child: Text(value.toLanguageString(locale).capitalize(locale), textAlign: TextAlign.end)
                                                      );
                                                    }).toList();
                                                  },
                                                  items: WorkoutType.values
                                                      .map<DropdownMenuItem<String>>((WorkoutType value) {
                                                    return DropdownMenuItem<String>(
                                                      value: value.name,
                                                      child: Text(value.toLanguageString(locale).capitalize(locale)),
                                                    );
                                                  }).toList(),
                                                )
                                              ],
                                            )
                                        ), // Type Dropdown
                                        ListTile(
                                            title: new Row(
                                              children: <Widget>[
                                                Text(AppLocalizations.of(context)!.metric),
                                                Spacer(),
                                                DropdownButton<String>(
                                                  value: metric,
                                                  iconSize: 24,
                                                  elevation: 16,
                                                  onChanged: widget.edit ? null : (value){
                                                    setState(() {metric = value!;});
                                                  },
                                                  underline: Container(
                                                    height: 2,
                                                  ),
                                                  selectedItemBuilder: (BuildContext context) {
                                                    return MetricType.values.map<Widget>((MetricType value) {
                                                      return Container(
                                                          alignment: Alignment.centerRight,
                                                          width: 100, // TODO: Find Proper Width
                                                          child: Text(value.name, textAlign: TextAlign.end)
                                                      );
                                                    }).toList();
                                                  },
                                                  items: MetricType.values
                                                      .map<DropdownMenuItem<String>>((MetricType value) {
                                                    return DropdownMenuItem<String>(
                                                      value: value.name,
                                                      child: Text(value.name),
                                                    );
                                                  }).toList(),
                                                )
                                              ],
                                            )
                                        ), // Metric Dropdown
                                      ],
                                    )
                                ),
                                if(!widget.edit)
                                  Container(
                                      padding: EdgeInsets.fromLTRB(20, 0, 0, 0),
                                      child: Row(
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.info_outline,
                                            size: 16,
                                            color: Colors.grey,
                                          ),
                                          Text(" " + AppLocalizations.of(context)!.workout_type_msg,
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: Colors.grey,
                                                fontSize: 12
                                            ),
                                          )
                                        ],
                                      )
                                  ),
                                Container(
                                    padding: EdgeInsets.fromLTRB(10, 10, 0, 0),
                                    child: Text(AppLocalizations.of(context)!.note,
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.grey
                                      ),
                                    )
                                ),
                                Card(
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
                                    margin: EdgeInsets.all(8.0),
                                    child: Column(
                                        children: <Widget>[
                                          ListTile(
                                              title: new Row(
                                                children: <Widget>[
                                                  new Flexible(
                                                      child: new TextFormField(
                                                        keyboardType: TextInputType.multiline,
                                                        maxLines: null,
                                                        minLines: 4,
                                                        controller: descriptionController,
                                                        decoration: InputDecoration(
                                                          border:InputBorder.none,
                                                          hintText: AppLocalizations.of(context)!.add_note,
                                                        ),
                                                      )
                                                  )
                                                ],
                                              )
                                          ),
                                        ]
                                    )
                                ),
                                /*
                                CardButton(
                                    Theme.of(context).colorScheme.primary,
                                    widget.edit ? AppLocalizations.of(context)!.save_changes : AppLocalizations.of(context)!.workout_add_workout,
                                        () {saveWorkout();}
                                ),
                                 */
                              ],
                            )
                        )
                )
            )
        )
    );
  }
}