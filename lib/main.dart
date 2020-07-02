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
  // Inicializa o Dio para ser usado no metodo POST
  final Dio dio = Dio();
  // Define a url da api google para FCM
  var url = 'https://fcm.googleapis.com/fcm/send';
  // declara e inicia a variável que exibira o token
  var _homeScreenText = "Esperando o Token...";
  // cria uma instancia do FCM
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
  // Declara os controllers para serem usados nas mensagens
  final _controllerTitle = TextEditingController();
  final _controllerBody = TextEditingController();
  final _controllerUsers = TextEditingController();

// Define uma lista de usuários estática.
  var users = <String, String>{
    'ismael':
        'eG1PIKS2QhSs3RVJqW1zBK:APA91bEpkK35uhEiEjtc2D5VnBCm48oXbcqedscpgz_Ho2DjWuOpfpukJr7TCPrxG1HZ1f1TKlrF0J-QPVnC7cBu2rLeegN78PbTeJwk_X9TTe5OFcDjPerbJGWOFfxCjASIYBhk-cuU',
  };

  // Desnecessario, mas serve para pegar o token do usuário
  Future<String> get userToken => _firebaseMessaging.getToken();

  @override
  void initState() {
    super.initState();
    // Requisita as permissões de notificação para o IOS, desnecessaria, nesse caso,
    // pois é somente para android.
    _firebaseMessaging.requestNotificationPermissions(
        const IosNotificationSettings(sound: true, alert: true, badge: true));
    _firebaseMessaging.onIosSettingsRegistered
        .listen((IosNotificationSettings settings) {
      print('Settings registred: $settings');
    });
    // Exibe o token do usuario
    _firebaseMessaging.getToken().then((String token) {
      assert(token != null);
      setState(() {
        _homeScreenText = 'Seu Token é: $token';
      });
      print(_homeScreenText);
      // aqui se configura o que acontece quando uma mensage for recebida, lançada ou clicada
      _firebaseMessaging.configure(
        onMessage: (Map<String, dynamic> message) async {
          print('onMessage: $message');
          setState(() {
            // muda o estado do homeScreenText para exibir a mensagem.
            _homeScreenText =
                'Titulo da mensagem: ${message['notification']['title']}\nA mensagem enviada é: ${message['notification']['body']}';
          });
        },
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text('Teste'),
          centerTitle: true,
        ),
        body: Material(
          child: Container(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  TextFormField(
                    // utiliza-se o controller anteriormente criado para capturar
                    // o texto escrito pelo usuário.
                    controller: _controllerUsers,
                    autocorrect: true,
                    decoration: InputDecoration(
                      labelText: 'To',
                    ),
                  ),
                  TextFormField(
                    controller: _controllerTitle,
                    decoration: InputDecoration(
                      labelText: 'Titulo',
                    ),
                  ),
                  TextFormField(
                    controller: _controllerBody,
                    decoration: InputDecoration(
                      labelText: 'Mensagem',
                    ),
                  ),
                  RaisedButton.icon(
                    onPressed: () async {
                      // incrementamos a mensagem que sera enviada com os dados
                      // fornecidos pelo usuário, no TextFormField.
                      dynamic menssagem = <String, dynamic>{
                        "to": "${users['${_controllerUsers.text}']}",
                        "notification": {
                          "title": "${_controllerTitle.text}",
                          "body": "${_controllerBody.text}",
                        },
                      };
                      // definimos o header com a key do servidor do FCM
                      dynamic headers = <String, dynamic>{
                        "Authorization": "key=SuaKey",
                      };
                      // Cria a requisição HTTP de metodo POST para o server GoogleAPI
                      Response response = await dio.post(
                        url,
                        data: menssagem,
                        options: Options(
                          headers: headers,
                          contentType: "application/json",
                        ),
                      );
                      // Desnecessario, mas serve para verificar se o _controllerUser
                      // está retornando o valor correto
                      print(
                          '$response |||||||| ${users['${_controllerUsers.text}']}');
                    },
                    icon: Icon(Icons.email),
                    label: Text(
                      'Enviar menssagem!',
                    ),
                  ),
                  Text(
                    '$_homeScreenText',
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
