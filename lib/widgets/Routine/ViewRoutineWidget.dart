import 'package:flutter/material.dart';
import 'package:fittracker/dbModels/routine_entry_model.dart';
import 'package:fittracker/dbModels/workout_entry_model.dart';
import 'package:fittracker/util/objectbox.dart';
import 'package:fittracker/util/typedef.dart';
import 'package:fittracker/widgets/Routine/AddEditRoutineEntryWidget.dart';
import 'package:fittracker/widgets/UIComponents.dart';
import 'package:fittracker/util/StringTool.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ViewRoutineEntryWidget extends StatefulWidget {
  late ObjectBox objectbox;
  late int id;
  ViewRoutineEntryWidget({Key? key, required this.objectbox, required this.id}) : super(key: key);

  @override
  State createState() => _ViewRoutineEntryState();
}

class _ViewRoutineEntryState extends State<ViewRoutineEntryWidget> {
  late RoutineEntry? routineEntry;
  String locale = "";

  List<String> partList = [];
  List<WorkoutEntry> WorkoutEntryList = [];

  @override
  void initState() {
    super.initState();
    String? temp = widget.objectbox.getPref("locale");
    locale = temp != null ? temp : 'en';

    updateInfo();
  }

  void updateInfo()
  {
    routineEntry = widget.objectbox.routineList.firstWhere((element) => element.id == widget.id);
    WorkoutEntryList.clear();
    partList = routineEntry!.parts;

    for(String i in routineEntry!.workoutIds) {
      WorkoutEntry? tmp = widget.objectbox.workoutBox.get(int.parse(i));
      if (tmp != null) {
        WorkoutEntryList.add(tmp);
      }
    }

    setState(() {});
  }

  Widget buildWorkoutCards(BuildContext context, int index) {
    return ListTile(
        title: new Row(
          children: <Widget>[
            new Flexible(
                child: new Text(
                  WorkoutEntryList[index].caption.capitalize(locale) + " (" + WorkoutType.values.firstWhere((element) => element.name == WorkoutEntryList[index].type).toLanguageString(locale) + ")",
                  style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold
                  ),
                )
            ),
          ],
        ),
    );
  }

  // List of Tags in partList
  List<Widget> selectedTagList()
  {
    List<Widget> tagList = [];

    for(int i = 0; i < partList.length; i++)
      tagList.add(tag(PartType.values.firstWhere((element) => element.name == partList[i]).toLanguageString(locale), (){}, Color.fromRGBO(210, 210, 210, 0.8)));
    return tagList;
  }

  void _openEditWidget(RoutineEntry entry) async {
    // start the SecondScreen and wait for it to finish with a   result
    bool result = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => AddRoutineEntryWidget(objectbox: widget.objectbox, edit:true, id:entry.id),
        ));
    if(result)
    {
      widget.objectbox.routineList.clear();
      widget.objectbox.routineList = widget.objectbox.routineBox.getAll();
      updateInfo();
    }
  }


  List<Widget> _buildActions() {
    return <Widget>[
      IconButton(
        icon: const Icon(Icons.edit),
        onPressed: (){
          _openEditWidget(routineEntry!);
        },
      ),
      IconButton(
          icon: Icon(Icons.delete),
          onPressed: () {
            confirmPopup(context,
              AppLocalizations.of(context)!.session_please_confirm,
              AppLocalizations.of(context)!.confirm_delete_msg,
              AppLocalizations.of(context)!.yes,
              AppLocalizations.of(context)!.no,).then((value) {
              if (value) {
                widget.objectbox.routineList.removeWhere((element) => element.id == routineEntry!.id);
                widget.objectbox.routineBox.remove(routineEntry!.id);
                Navigator.pop(context, true);
              }
            });
          }
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () async{
          Navigator.pop(context, false);
          return true;
        },
        child: new GestureDetector(
            onTap: () {
              FocusScope.of(context).unfocus();
            },
            child: new Scaffold(
                appBar: AppBar(
                  title: Text(AppLocalizations.of(context)!.routine_details),
                  backgroundColor: Colors.deepPurpleAccent,
                  actions: _buildActions(),
                ),
                body: Builder(
                    builder: (context) =>
                        SingleChildScrollView(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Container(
                                    padding: EdgeInsets.fromLTRB(15, 15, 0, 0),
                                    child: Text(routineEntry!.name,
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 32,
                                          color: Colors.black87
                                      ),
                                    )
                                ),
                                if(routineEntry!.parts.length > 0)
                                    Container(
                                    margin: EdgeInsets.fromLTRB(20, 5, 10, 0),
                                     child: Wrap(
                                        alignment: WrapAlignment.start,
                                        children: selectedTagList()
                                     ),
                                   ),
                                Container(
                                    padding: EdgeInsets.fromLTRB(10, 10, 0, 0),
                                    child: Text(AppLocalizations.of(context)!.routine_details,
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.grey
                                      ),
                                    )
                                ),
                                Card(
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
                                    margin: EdgeInsets.all(6.0),
                                    child: Column(
                                      children: <Widget>[
                                        ListView.builder(
                                          itemCount: WorkoutEntryList.length,
                                          itemBuilder: buildWorkoutCards,
                                          physics: NeverScrollableScrollPhysics(),
                                          shrinkWrap: true,
                                        ),
                                      ]
                                    )
                                ),
                                if(routineEntry!.description.isNotEmpty)
                                  Container(
                                      padding: EdgeInsets.fromLTRB(10, 10, 0, 0),
                                      child: Text(AppLocalizations.of(context)!.note,
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.grey
                                        ),
                                      )
                                  ),
                                if(routineEntry!.description.isNotEmpty)
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
                                                        controller: TextEditingController()..text = routineEntry!.description,
                                                        maxLines: null,
                                                        minLines: 3,
                                                        enabled: false,
                                                        decoration: InputDecoration(
                                                          border:InputBorder.none,
                                                        ),
                                                      )
                                                  )
                                                ],
                                              )
                                          ),
                                        ]
                                    )
                                 ),
                              ],
                            )
                        )
                )
            )
        )
    );
  }
}