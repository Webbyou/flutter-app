import 'package:flutter/material.dart';
import 'package:todo_open/style/style.dart' as prefix0;
import '../../style/style.dart';
import '../../screens/auth/register.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../screens/home/landing.dart';
import 'package:flutter_facebook_login/flutter_facebook_login.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import 'dart:convert' show json;
import 'package:http/http.dart' as http;
import 'package:flutter_twitter_login/flutter_twitter_login.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../common/constant.dart';
import 'dart:convert';
import '../../screens/auth/reset_password.dart';

class Login extends StatefulWidget {
  static String tag = "login";
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _passwordTextController = TextEditingController();

  bool value1 = true;
  String email, password;
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  void onChangedValue1(bool value) {
    setState(() {
      value1 = value;
    });
  }


  bool loading = false;
  var errorText;

  Future<void> signInUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('login', true);
    setState(() {
      loading = true;
    });
    // Navigator.of(context).pushNamed(Landing.tag);
    final FormState form = _formKey.currentState;
    if (!form.validate()) {
      return;
    } else {
      form.save();

      try {
        FirebaseUser user = await auth.signInWithEmailAndPassword(
            email: email, password: password);
        setState(() {
          loading = false;
        });

        print('onval $user');
        prefs.setString('user', '${user.email}');

        Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (BuildContext context) => Landing(),
            ),
            (Route<dynamic> route) => false);
      } catch (onError) {
        setState(() {
          loading = false;
        });
        print('onnnnnn $onError');
        errorText = onError.toString().split(',')[1];
        showDialog<Null>(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return Container(
              width: 270.0,
              child: new AlertDialog(
                title: new Text('Please!!'),
                content: new SingleChildScrollView(
                  child: new ListBody(
                    children: <Widget>[
                      new Text('$errorText'),
                    ],
                  ),
                ),
                actions: <Widget>[
                  new FlatButton(
                    child: new Text('ok'),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
            );
          },
        );
      }
    }
  }

  fbLoginUser(
    id,
    name,
    email,
  ) async {
    var authData = {
      'facebookId': id,
      'name': name,
    };
    var data = json.encode(authData);
    print(json.encode(authData));
    print("facebook..............................$data");
  }

  static final FacebookLogin facebookSignIn = new FacebookLogin();

  String message = 'Log in/out by pressing the buttons below.';
  bool fbLog = false;

  putData(accessToken, data) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      loading = true;
    });
    await fbLoginUser(accessToken.userId, data['name'], data['email'])
        .then((response) {
      print("data......................$data");
      prefs.setString('fbuser', '${data['name']}');
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (BuildContext context) => Landing(),
        ),
      );
    });
    setState(() {
      loading = false;
    });
  }

  facebookLog(accessToken) async {
    await http
        .get(
            'https://graph.facebook.com/me?access_token=${accessToken.token}&fields=id,name,email,picture.type(large)')
        .then((res) {
      //	console.log('result ---' + JSON.stringify(res));
      //console.log('user image url==' + JSON.stringify(res.data.picture.data.url));
      String resp = res.body;
      var data = json.decode(resp);

      putData(accessToken, data);
      print('fb data---> $data');
    });
  }

  Future<Null> _facebookLogin() async {
    final FacebookLoginResult result = await facebookSignIn
        .logInWithReadPermissions(['public_profile, email']);

    switch (result.status) {
      case FacebookLoginStatus.loggedIn:
        final FacebookAccessToken accessToken = result.accessToken;
        print('token $accessToken');
        setState(() {
          fbLog = true;
        });
        await facebookLog(accessToken);
        break;
      case FacebookLoginStatus.cancelledByUser:
        print('cancel');
        await facebookSignIn.logOut();
        _showMessage('Logged out.');
        setState(() {
          fbLog = false;
        });
        _showMessage('Login cancelled by the user.');
        break;
      case FacebookLoginStatus.error:
        print('error');
        _showMessage('Something went wrong with the login process.\n'
            'Here\'s the error Facebook gave us: ${result.errorMessage}');
        break;
    }
  }

  void _showMessage(String message) {
    setState(() {
      message = message;
    });
  }

  static final TwitterLogin twitterLogin = new TwitterLogin(
    consumerKey: '1OR06t702rtEEMGEDhe5Lfxpd',
    consumerSecret: 'vw7jKpy45DlE8Y0wpB5o886olhTgwsfFbLoRTmftWRGQ1qQwnT',
  );

  String _message = 'Logged out.';

  void _twitterLogin() async {
    final TwitterLoginResult result = await twitterLogin.authorize();
    String newMessage;

    switch (result.status) {
      case TwitterLoginStatus.loggedIn:
        newMessage = 'Logged in! username: ${result.session.username}';
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (BuildContext context) => Landing(),
          ),
        );
        break;
      case TwitterLoginStatus.cancelledByUser:
        newMessage = 'Login cancelled by user.';
        break;
      case TwitterLoginStatus.error:
        newMessage = 'Login error: ${result.errorMessage}';
        break;
    }

    setState(() {
      _message = newMessage;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      key: _scaffoldKey,
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).requestFocus(new FocusNode());
        },
        child: Stack(
          alignment: AlignmentDirectional.center,
          fit: StackFit.expand,
          children: <Widget>[
            new Image(
              image: new AssetImage("lib/assets/bg/image.png"),
              fit: BoxFit.cover,
            ),
            Positioned(
              top: 80.0,
              child: Align(
                alignment: AlignmentDirectional.topStart,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Container(
                      padding: EdgeInsets.fromLTRB(30.0, 40.0, 30.0, 0.0),
                      child: Image(
                        image: AssetImage("lib/assets/icon/logo.png"),
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.fromLTRB(30.0, 40.0, 0.0, 30.0),
                      child: Text(
                        "Login If you have an account",
                        style: subTitleWhite2SR(),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Form(
                      key: _formKey,
                      child: Theme(
                        data: ThemeData(
                          brightness: Brightness.dark,
                          accentColor: primary,
                          inputDecorationTheme: new InputDecorationTheme(
                            labelStyle: new TextStyle(
                              color: primary,
                              fontSize: 16.0,
                            ),
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            Container(
                              padding: EdgeInsets.fromLTRB(30.0, 0.0, 30.0, 15.0),
                              child: Stack(
                                children: <Widget>[
                                  Container(
                                    width: screenWidth(context)*0.83,
                                    color: Colors.white,
                                    padding: EdgeInsets.only(left: 65.0),
                                    child: TextFormField(
                                      textAlign: TextAlign.left,
                                      cursorColor: border,
                                      decoration: InputDecoration(
                                        border: InputBorder.none,
                                        hintText: 'User Name',
                                        hintStyle: hintStyleDark(),
                                      ),
                                      style: hintStyleDark(),
                                      keyboardType: TextInputType.emailAddress,
                                      validator: (String value) {
                                        if (value.isEmpty ||
                                            !RegExp(r"[a-z0-9!#$%&'*+/=?^_`{|}~-]+(?:\.[a-z0-9!#$%&'*+/=?^_`{|}~-]+)*@(?:[a-z0-9](?:[a-z0-9-]*[a-z0-9])?\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?")
                                                .hasMatch(value)) {
                                          return 'Please enter a valid email';
                                        }
                                      },
                                      onSaved: (String value) {
                                        email = value;
                                      },
                                    ),
                                  ),
                                  Positioned(
                                    top: -6.0,
                                  right: (screenWidth(context) * 0.83) - 55.0,
                                    child: Stack(
                                      fit: StackFit.loose,
                                      alignment: AlignmentDirectional.center,
                                      children: <Widget>[
                                        Image.asset("lib/assets/icon/send.png"),
                                        Padding(
                                          padding: EdgeInsets.only(
                                              bottom: 8.0, left: 2.0),
                                          child: Icon(
                                            FontAwesomeIcons.user,
                                            color: Colors.white,
                                            size: 16.0,
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                                ],
                              ),
                            ),
                            Container(
                              padding:
                              EdgeInsets.fromLTRB(30.0, 0.0, 30.0, 0.0),
                              child: Stack(
                                children: <Widget>[
                                  Container(
                                    width: screenWidth(context)*0.83,
                                    color: Colors.white,
                                    padding: EdgeInsets.only(left: 65.0),
                                    child: TextFormField(
                                      cursorColor: border,
                                      textAlign: TextAlign.left,
                                      decoration: new InputDecoration(
                                        border: InputBorder.none,
                                        hintText: 'Password',
                                        hintStyle: hintStyleDark(),
                                      ),
                                      keyboardType: TextInputType.text,
                                      style: hintStyleDark(),
                                      validator: (String value) {
                                        if (value.isEmpty || value.length < 6) {
                                          return 'Password invalid';
                                        }
                                      },
                                      controller: _passwordTextController,
                                      onSaved: (String value) {
                                        password = value;
                                      },
                                      obscureText: true,
                                    ),
                                  ),
                                  Positioned(
                                    top: -6.0,
                                    right: (screenWidth(context) * 0.83) - 55.0,
                                    child: Stack(
                                      fit: StackFit.loose,
                                      alignment: AlignmentDirectional.center,
                                      children: <Widget>[
                                        Image.asset("lib/assets/icon/send.png"),
                                        Padding(
                                          padding: EdgeInsets.only(
                                              bottom: 8.0, left: 2.0),
                                          child: Icon(
                                            Icons.lock_outline,
                                            color: Colors.white,
                                            size: 18.0,
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                                ],
                              ),
                            ),
                            Container(
                              width: screenWidth(context),
                              padding: const EdgeInsets.only(
                                  left: 16.0, right: 30.0),
                              child: Row(
                                mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: <Widget>[
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: <Widget>[
                                      Checkbox(
                                        value: value1,
                                        onChanged: onChangedValue1,
                                        activeColor: secondary,
                                      ),
                                      Text(
                                        "Remember me",
                                        style: smallAddressWhiteSR(),
                                      ),
                                    ],
                                  ),
                                  InkWell(
                                    onTap: () {
                                      Navigator.of(context).pushNamed(ResetPassword.tag);
                                    },
                                    child: Text(
                                      "Forget Password",
                                      style: smallAddressWhiteSR(),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Padding(
                              padding: EdgeInsetsDirectional.only(
                                  top: 15.0,
                                  start: 45.0,
                                  end: 45.0,
                                  bottom: 10.0),
                              child: RawMaterialButton(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(5.0),
                                ),
                                fillColor: secondary,
                                child: Container(
                                  height: 45.0,
                                  width: screenWidth(context) * 0.5,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(5.0),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      Text(
                                        'LOGIN',
                                        style: subTitleWhiteSR(),
                                      ),
                                      new Padding(
                                        padding: new EdgeInsets.only(
                                            left: 5.0, right: 5.0),
                                      ),
                                      loading
                                          ? new Image.asset(
                                        'lib/assets/gif/load.gif',
                                        width: 19.0,
                                        height: 19.0,
                                      )
                                          : new Text(''),
                                    ],
                                  ),
                                ),
                                onPressed: signInUser,
                                splashColor: secondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
            Align(
              alignment: AlignmentDirectional.bottomCenter,
              child: ListView(
                padding: EdgeInsets.only(left: 30.0, right: 30.0, bottom: 14.0),
                shrinkWrap: true,
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        "Or Sign In using",
                        style: subTitleWhite2SR(),
                      ),
                    ],
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: 30.0, bottom: 30.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Flexible(
                            flex: 6,
                            child: InkWell(
                              onTap: _facebookLogin,
                              child: Row(
                                mainAxisAlignment:
                                MainAxisAlignment.spaceEvenly,
                                crossAxisAlignment:
                                CrossAxisAlignment.center,
                                children: <Widget>[
                                  Container(
                                    height: 50.0,
                                    width: 50.0,
                                    decoration: BoxDecoration(
                                      borderRadius:
                                      BorderRadius.circular(8.0),
                                      color: Colors.white,
                                    ),
                                    child: new Icon(
                                      FontAwesomeIcons.facebookF,
                                      color: Colors.grey.shade700,
                                      size: 20.0,
                                    ),
                                  ),
                                  Text(
                                    "Facebook",
                                    style: categoryWhiteSR(),
                                  )
                                ],
                              ),
                            )),
//                                Padding(padding: new EdgeInsets.all(15.0)),
                        Flexible(
                          flex: 6,
                          child: InkWell(
                            onTap: _twitterLogin,
                            child: Row(
                              mainAxisAlignment:
                              MainAxisAlignment.spaceEvenly,
                              crossAxisAlignment:
                              CrossAxisAlignment.center,
                              children: <Widget>[
                                Container(
                                  decoration: BoxDecoration(
                                    borderRadius:
                                    BorderRadius.circular(8.0),
                                    color: Colors.white,
                                  ),
                                  height: 50.0,
                                  width: 50.0,
                                  child: new Icon(
                                    FontAwesomeIcons.twitter,
                                    color: Colors.grey.shade700,
                                    size: 20.0,
                                  ),
                                ),
                                Text(
                                  "Twitter",
                                  style: categoryWhiteSR(),
                                )
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      Navigator.of(context).pushNamed(Register.tag);
                    },
                    child: Container(
                      alignment: AlignmentDirectional.center,
                      child: Text(
                        "Don't Have an Account? Register",
                        style: subTitleWhiteUnderline2SR(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
