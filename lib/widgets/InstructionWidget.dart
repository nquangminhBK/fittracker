import 'package:firebase_auth/firebase_auth.dart';
import 'package:fittracker/util/loading_utils.dart';
import 'package:flutter/material.dart';
import 'package:fittracker/dbModels/workout_entry_model.dart';
import 'package:fittracker/main.dart';
import 'package:fittracker/util/initialWorkouts.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:fittracker/util/typedef.dart';
import 'package:google_sign_in/google_sign_in.dart';

class InstructionWidget extends StatefulWidget {
  final BuildContext parentCtx;
  late final objectbox;

  InstructionWidget({Key? key, required this.parentCtx, required this.objectbox});

  @override
  State createState() => _InstructionState();
}

class _InstructionState extends State<InstructionWidget> {
  final pageController = PageController(initialPage: 0);
  String userName = "";
  Map<String, String> languages = {'English': 'en', '한국어': 'kr'};

  String distance = "km";
  String weight = "kg";
  int _currentIndex = 0;
  String locale = "";

  @override
  void initState() {
    super.initState();
    String? temp = objectbox.getPref("locale");
    locale = temp != null ? temp : 'en';
  }

  void setLanguage(String language) {
    Locale newLocale = Locale(language, '');
    widget.objectbox.setPref("locale", language);
    MyApp.setLocale(context, newLocale);
    setState(() {});
  }

  void loginWithGoogle(BuildContext context) async {
    LoadingUtils.instance.showLoading();
    try {
      GoogleSignIn().signIn().then((googleUser) async {
        final GoogleSignInAuthentication? googleAuth = await googleUser?.authentication;
        print("minh check idToken, ${googleAuth?.idToken??""}");
        print("minh check accessToken, ${googleAuth?.accessToken??""}");
        if (googleAuth != null) {
          final credential = GoogleAuthProvider.credential(
            accessToken: googleAuth?.accessToken,
            idToken: googleAuth?.idToken,
          );
          print("minh check credential $credential");
          await FirebaseAuth.instance.signInWithCredential(credential).then((userCredential) async {
            print("minh check $userCredential");
            LoadingUtils.instance.hideLoading();
            print(googleUser);
            if (googleUser == null) return;
            String userAvatar = googleUser.photoUrl ?? "";
            userName = googleUser.displayName ?? "";
            String email = googleUser.email ?? "";
            String userId = googleUser.id ?? "";
            nextPage();
          }, onError: (e) {
            print("minh check error1 $e");
            showSnackBar(
              context,
              AppLocalizations.of(context)!.loginError,
            );
            LoadingUtils.instance.hideLoading();
          });
        } else {
          LoadingUtils.instance.hideLoading();
        }
      }, onError: (e) {
        showSnackBar(
          context,
          AppLocalizations.of(context)!.loginError,
        );
        print("minh check error2 $e");
        LoadingUtils.instance.hideLoading();
      });
    } catch (e) {
      print("minh check error3 $e");
      showSnackBar(
        context,
        AppLocalizations.of(context)!.loginError,
      );
      LoadingUtils.instance.hideLoading();
    }
  }

  finishSplash() async {
    nextPage();
    objectbox.setPref('show_instruction', false);
    objectbox.setPref('user_name', userName);
    objectbox.setPref('version', '1.0.0');
    addInitialWorkouts();
    await Future.delayed(const Duration(seconds: 2), () {});
    Navigator.of(context).pushNamedAndRemoveUntil('/home', (Route<dynamic> route) => false);
  }

  nextPage() {
    setState(() {
      _currentIndex += 1;
      pageController.animateToPage(_currentIndex,
          duration: Duration(milliseconds: 500), curve: Curves.ease);
    });
  }

  showSnackBar(BuildContext context, String s) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(s),
      duration: Duration(seconds: 3),
    ));
  }

  Widget languageScreen(BuildContext context) {
    return new GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: new Scaffold(
            body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.all(15),
              child: Center(
                  child: Image(
                image: AssetImage('assets/languages.png'),
                width: 150,
              )),
            ),
            Padding(
                padding: EdgeInsets.fromLTRB(20, 10, 20, 10),
                child: Center(
                    child: Text(
                  AppLocalizations.of(context)!.instruction_select_language,
                  style: TextStyle(
                    fontSize: 20,
                  ),
                ))),
            Center(
              child: DropdownButtonHideUnderline(
                child: DropdownButton2(
                  isExpanded: true,
                  items: languages.keys
                      .toList()
                      .map((item) => DropdownMenuItem<String>(
                            value: item,
                            child: Text(
                              item,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ))
                      .toList(),
                  value: languages.keys.firstWhere((element) => languages[element] == locale),
                  onChanged: (value) {
                    setState(() {
                      String? newLocale = languages[value];
                      locale = newLocale!;
                      setLanguage(locale);
                    });
                  },
                  icon: const Icon(
                    Icons.arrow_drop_down,
                  ),
                  iconSize: 14,
                  iconEnabledColor: Colors.grey,
                  iconDisabledColor: Colors.grey,
                  buttonHeight: 50,
                  buttonWidth: MediaQuery.of(context).size.width - 50,
                  buttonPadding: const EdgeInsets.only(left: 14, right: 14),
                  buttonDecoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: Colors.black26,
                    ),
                  ),
                  buttonElevation: 1,
                  itemHeight: 50,
                  itemPadding: const EdgeInsets.only(left: 14, right: 14),
                  dropdownMaxHeight: 200,
                  dropdownWidth: 200,
                  dropdownPadding: null,
                  dropdownDecoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  dropdownElevation: 8,
                  scrollbarRadius: const Radius.circular(40),
                  scrollbarThickness: 6,
                  scrollbarAlwaysShow: true,
                  offset: const Offset(0, 0),
                ),
              ),
            ),
            GestureDetector(
              onTap: () {
                nextPage();
              },
              child: Container(
                  width: MediaQuery.of(context).size.width - 50,
                  child: Card(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
                      margin: EdgeInsets.fromLTRB(0, 15, 0, 10),
                      color: Colors.deepPurple,
                      child: Center(
                          child: Container(
                        margin: EdgeInsets.only(top: 15, bottom: 15),
                        child: Text(
                          AppLocalizations.of(context)!.next,
                          style: TextStyle(fontSize: 18, color: Colors.white),
                          textAlign: TextAlign.center,
                        ),
                      )))),
            )
          ],
        )));
  }

  Widget introScreen(BuildContext context) {
    return new GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: new Scaffold(
            body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.all(15),
              child: Center(
                  child: Image(
                image: AssetImage('assets/my_icon.png'),
                width: 150,
              )),
            ),
            Padding(
                padding: EdgeInsets.fromLTRB(40, 10, 40, 10),
                child: Center(
                    child: Text(
                  AppLocalizations.of(context)!.instruction_ask_name_msg,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 20,
                  ),
                ))),
            // Card(
            //     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
            //     margin: EdgeInsets.fromLTRB(20, 0, 20, 0),
            //     child: Center(
            //       child: ListTile(
            //           title: new Row(
            //         children: <Widget>[
            //           Flexible(
            //               child: TextField(
            //             decoration: InputDecoration(
            //               border: InputBorder.none,
            //               hintText: AppLocalizations.of(context)!.enter_name,
            //             ),
            //             controller: userName,
            //             textAlign: TextAlign.center,
            //           ))
            //         ],
            //       )),
            //     )),
            GestureDetector(
              onTap: () {
                loginWithGoogle(context);
              },
              child: Card(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
                  margin: EdgeInsets.fromLTRB(20, 10, 20, 10),
                  color: Colors.deepPurple,
                  child: Center(
                      child: Container(
                    margin: EdgeInsets.only(top: 15, bottom: 15),
                    child: Text(
                      'Continue with Google',
                      style: TextStyle(fontSize: 18, color: Colors.white),
                      textAlign: TextAlign.center,
                    ),
                  ))),
            )
          ],
        )));
  }

  Widget metricScreen(BuildContext context) {
    return new GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: new Scaffold(
            body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.all(15),
              child: Center(
                  child: Image(
                image: AssetImage('assets/settings.png'),
                width: 150,
              )),
            ),
            Padding(
                padding: EdgeInsets.fromLTRB(40, 10, 40, 10),
                child: Center(
                    child: Text(
                  AppLocalizations.of(context)!.instruction_initial_setting,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 20,
                  ),
                ))),
            Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
                margin: EdgeInsets.fromLTRB(20, 8, 20, 4),
                child: Column(
                  children: <Widget>[
                    ListTile(
                        title: new Row(
                      children: <Widget>[
                        Text(AppLocalizations.of(context)!.instruction_default_weight),
                        Spacer(),
                        DropdownButton<String>(
                          value: weight,
                          iconSize: 24,
                          elevation: 16,
                          onChanged: (value) {
                            setState(() {
                              weight = value!;
                            });
                          },
                          underline: Container(
                            height: 2,
                          ),
                          selectedItemBuilder: (BuildContext context) {
                            return ["kg", "lb"].map<Widget>((String value) {
                              return Container(
                                  alignment: Alignment.centerRight,
                                  width: 100, // TODO: Find Proper Width
                                  child: Text(value, textAlign: TextAlign.end));
                            }).toList();
                          },
                          items: ["kg", "lb"].map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                        )
                      ],
                    )),
                    ListTile(
                        title: new Row(
                      children: <Widget>[
                        Text(AppLocalizations.of(context)!.instruction_default_distance),
                        Spacer(),
                        DropdownButton<String>(
                          value: distance,
                          iconSize: 24,
                          elevation: 16,
                          onChanged: (value) {
                            setState(() {
                              distance = value!;
                            });
                          },
                          underline: Container(
                            height: 2,
                          ),
                          selectedItemBuilder: (BuildContext context) {
                            return ["km", "miles"].map<Widget>((String value) {
                              return Container(
                                  alignment: Alignment.centerRight,
                                  width: 100, // TODO: Find Proper Width
                                  child: Text(value, textAlign: TextAlign.end));
                            }).toList();
                          },
                          items: ["km", "miles"].map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                        )
                      ],
                    )),
                  ],
                )),
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
                    Expanded(
                      child: Text(
                        " " + AppLocalizations.of(context)!.instruction_metric_note,
                        style: TextStyle(
                            fontWeight: FontWeight.bold, color: Colors.grey, fontSize: 12),
                      ),
                    )
                  ],
                )),
            GestureDetector(
              onTap: () {
                if (userName.isEmpty) {
                  final snackBar = SnackBar(
                    content: Text(AppLocalizations.of(context)!.instruction_name_msg),
                  );
                  ScaffoldMessenger.of(context).showSnackBar(snackBar);
                  return;
                }
                finishSplash();
              },
              child: Card(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
                  margin: EdgeInsets.fromLTRB(20, 10, 20, 10),
                  color: Colors.deepPurple,
                  child: Center(
                    child: Container(
                      margin: EdgeInsets.only(top: 15, bottom: 15),
                      child: Text(
                        AppLocalizations.of(context)!.start,
                        style: TextStyle(fontSize: 18, color: Colors.white),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  )),
            )
          ],
        )));
  }

  Widget loadingScreen(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Container(
          padding: EdgeInsets.all(20),
          child: Center(
              child: Text(AppLocalizations.of(context)!.instruction_creating_db,
                  textAlign: TextAlign.center, style: TextStyle(fontSize: 16))),
        ),
        SpinKitPouringHourGlassRefined(color: Colors.deepPurpleAccent),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> introPages = <Widget>[
      languageScreen(context),
      introScreen(context),
      metricScreen(context),
      loadingScreen(context)
    ];
    return Scaffold(
      body: Builder(
          builder: (context) => PageView(
              physics: new NeverScrollableScrollPhysics(),
              onPageChanged: (index) {
                FocusScope.of(context).unfocus();
                _currentIndex = index;
              },
              controller: pageController,
              children: introPages)),
    );
  }

  void addInitialWorkouts() async {
    for (WorkoutEntry entry in initList) {
      if (entry.metric == MetricType.kg.name) entry.metric = weight;
      if (entry.metric == MetricType.km.name) entry.metric = distance;

      widget.objectbox.workoutBox.put(entry);
    }

    widget.objectbox.workoutList = widget.objectbox.workoutBox.getAll();
    setState(() {});
  }
}
