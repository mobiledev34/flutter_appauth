import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_appauth/flutter_appauth.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  FlutterAppAuth _appAuth = FlutterAppAuth();
  String _refreshToken;
  String _accessToken;
  TextEditingController _accessTokenTextController = TextEditingController();
  TextEditingController _accessTokenExpirationTextController =
      TextEditingController();

  TextEditingController _idTokenTextController = TextEditingController();
  TextEditingController _refreshTokenTextController = TextEditingController();
  String _userInfo = '';
  String _clientId =
      '511828570984-fuprh0cm7665emlne3rnf9pk34kkn86s.apps.googleusercontent.com';
  String _redirectUrl = 'com.google.codelabs.appauth:/oauth2callback';

  AuthorizationServiceConfiguration _authorizationServiceConfiguration =
      AuthorizationServiceConfiguration(
          'https://accounts.google.com/o/oauth2/v2/auth',
          'https://www.googleapis.com/oauth2/v4/token');
  List<String> _scopes = ['profile'];
  @override
  void initState() {
    super.initState();
  }

  Future _refresh() async {
    var result = await _appAuth.refresh(RefreshRequest(
        _clientId, _redirectUrl, _refreshToken,
        serviceConfiguration: _authorizationServiceConfiguration,
        scopes: _scopes));
    _processTokenResponse(result);
    await _getUserInfo(result);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              RaisedButton(
                child: Text('Sign in'),
                onPressed: () async {
                  var result = await _appAuth.authorize(
                    AuthorizationRequest(
                      _clientId,
                      _redirectUrl,
                      serviceConfiguration: _authorizationServiceConfiguration,
                      scopes: _scopes,
                    ),
                  );
                  if (result != null) {
                    _processAuthTokenResponse(result);
                    await _getUserInfo(result);
                  }
                },
              ),
              RaisedButton(
                child: Text('Refresh token'),
                onPressed: _refreshToken != null ? _refresh : null,
              ),
              Text('access token'),
              TextField(
                controller: _accessTokenTextController,
              ),
              Text('access token expiration'),
              TextField(
                controller: _accessTokenExpirationTextController,
              ),
              Text('id token'),
              TextField(
                controller: _idTokenTextController,
              ),
              Text('refresh token'),
              TextField(
                controller: _refreshTokenTextController,
              ),
              Text('user info'),
              Text(_userInfo),
            ],
          ),
        ),
      ),
    );
  }

  void _processAuthTokenResponse(AuthorizationTokenResponse response) {
    setState(() {
      _accessToken = _accessTokenTextController.text = response.accessToken;
      _idTokenTextController.text = response.idToken;
      _refreshToken = _refreshTokenTextController.text = response.refreshToken;
      _accessTokenExpirationTextController.text =
          response.accessTokenExpirationTime == null
              ? null
              : DateTime.fromMillisecondsSinceEpoch(
                      response.accessTokenExpirationTime)
                  .toIso8601String();
    });
  }

  void _processTokenResponse(TokenResponse response) {
    setState(() {
      _accessTokenTextController.text = response.accessToken;
      _idTokenTextController.text = response.idToken;
      _refreshToken = _refreshTokenTextController.text = response.refreshToken;
      _accessTokenExpirationTextController.text =
          response.accessTokenExpirationTime == null
              ? null
              : DateTime.fromMillisecondsSinceEpoch(
                      response.accessTokenExpirationTime)
                  .toIso8601String();
    });
  }

  Future _getUserInfo(TokenResponse response) async {
    var httpResponse = await http.get(
        'https://www.googleapis.com/oauth2/v3/userinfo',
        headers: {'Authorization': 'Bearer $_accessToken'});
    setState(() {
      _userInfo = httpResponse.statusCode == 200 ? httpResponse.body : '';
    });
  }
}
