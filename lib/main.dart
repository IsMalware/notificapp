import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:dio/dio.dart';

void main() => runApp(StartApp());

class StartApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TEST APP',
      home: Home(),
    );
  }
}

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final controllerTitle = TextEditingController();
  final controllerBody = TextEditingController();
  final controllerUsers = TextEditingController();
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();

  Response response = Response();
  Stopwatch stopwatch = Stopwatch();

  var time = 0;
  var totalNotifica = 0;
  var _token;
  var homeScreenText;

  @override
  void initState() {
    _firebaseMessaging.getToken().then((token) {
      setState(() {
        _token = token;
        assert(_token != null);
        homeScreenText = 'Seu Token é: $token';
        print(homeScreenText);
      });
    });
    super.initState();
    _firebaseMessaging.requestNotificationPermissions(
        const IosNotificationSettings(sound: true, alert: true, badge: true));
    _firebaseMessaging.onIosSettingsRegistered
        .listen((IosNotificationSettings settings) {
      print('Settings registred: $settings');
    });
    // aqui se configura o que acontece quando uma mensage for recebida, lançada ou clicada
    setState(() {
      configureFireMsg(_firebaseMessaging, homeScreenText);
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: _appBar('Testando'),
        body: _body(),
      ),
    );
  }

  Map<String, dynamic> configureFireMsg(
      FirebaseMessaging _firebaseMessaging, String homeScreenText) {
    _firebaseMessaging.configure(
      onMessage: (Map<String, dynamic> message) async {
        return homeScreenText =
            'Titulo da mensagem: ${message['notification']['title']}\nA mensagem enviada é: ${message['notification']['body']}';
      },
    );
    return null;
  }

  Widget _appBar(String title) {
    return AppBar(
      title: Text('$title'),
      centerTitle: true,
    );
  }

  Widget _form(String labelText, TextEditingController controller) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: '$labelText',
      ),
    );
  }

  Widget _body() {
    return Material(
      child: Container(
        height: MediaQuery.of(context).size.height,
        padding: const EdgeInsets.all(15),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              _form('Para:', controllerUsers),
              _form('Titulo: ', controllerTitle),
              _form('Mensagem', controllerBody),
              RaisedButton.icon(
                onPressed: () {
                  stopwatch.start();
                  notifica();
                  setState(() {
                    time = stopwatch.elapsed.inMilliseconds;
                  });
                  stopwatch.stop();
                },
                icon: Icon(Icons.email),
                label: Text(
                  'Enviar notificação!',
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text('$totalNotifica Notificações'),
                  Text(time.toString() + 'ms'),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void notifica() async {
    final Dio dio = Dio();
    var url = 'https://fcm.googleapis.com/fcm/send';

    var users = <String, String>{
      'ismael':
          'G1PIKS2QhSs3RVJqW1zBK:APA91bEpkK35uhEiEjtc2D5VnBCm48oXbcqedscpgz_Ho2DjWuOpfpukJr7TCPrxG1HZ1f1TKlrF0J-QPVnC7cBu2rLeegN78PbTeJwk_X9TTe5OFcDjPerbJGWOFfxCjASIYBhk-cuU',
      'joão': 'awdomjnahsdnjwmkladl',
    };

    dynamic menssagem = <String, dynamic>{
      'to': '${users['${controllerUsers.text}']}',
      'notification': {
        'title': '${controllerTitle.text}',
        'body': '${controllerBody.text}',
      },
    };
    dynamic headers = <String, dynamic>{
      "Authorization":
          "key=AAAAeEBcmts:APA91bF_XffpBkECEOMPYuddDp39w27Q0jBat3fUskE83h8SODwqRQHxkzRftP0r0BLiAFiu-s-fI3_0Ahy5ktNs2iAKVlimDcKAsisCF5gZxWGKnhShCuX5vnDp8eK1s-orqQfSQN6Z",
    };
    response = await dio.post(
      url,
      data: menssagem,
      options: Options(
        headers: headers,
        contentType: "application/json",
      ),
    );
    if (response.statusCode != 200) {
      return null;
    } else {
      setState(() {
        totalNotifica++;
      });
    }
  }
}
