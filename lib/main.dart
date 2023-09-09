import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        backgroundColor: Colors.black,
        body: Column(
          children: [
            SizedBox(
              height: 80,
            ),
            Row(
              children: [
                SizedBox(
                  width: 5,
                ),
                Text(
                  "Text Translation",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 0, 8, 0),
              child: Divider(
                color: Colors.grey[850],
                height: 50,
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Container(height: 50, child: LanguageList()),
                Icon(
                  Icons.swap_horiz,
                  size: 20,
                  color: Colors.grey,
                ),
                Container(height: 50, child: LanguageList()),
              ],
            ),
            SizedBox(
              height: 30,
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: MyTextField(),
            ),
            SizedBox(
              height: 30,
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: MySecondTextField(),
            ),
          ],
        ),
      ),
    );
  }
}

class MyTextField extends StatefulWidget {
  @override
  _MyTextFieldState createState() => _MyTextFieldState();
}

class _MyTextFieldState extends State<MyTextField> {
  String q = '';
  String selectedLanguage = '';
  String sourceLanguage = 'en';

  @override
  Widget build(BuildContext context) {
    return TextField(
      style: TextStyle(color: Colors.white),
      maxLines: 4,
      onChanged: (text) {
        setState(() {
          q = text;
        });
        fetchTranslation(text, selectedLanguage, sourceLanguage);

        _updateSecondTextFieldText(text);
      },
      decoration: InputDecoration(
          filled: true,
          fillColor: Colors.grey[850],
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          hintText: 'Type..',
          hintStyle: TextStyle(color: Colors.white)),
    );
  }

  void _updateSecondTextFieldText(String text) {
    MySecondTextFieldState.updateText(text);
  }
}

class MySecondTextField extends StatefulWidget {
  @override
  MySecondTextFieldState createState() => MySecondTextFieldState();
}

class MySecondTextFieldState extends State<MySecondTextField> {
  static TextEditingController textController = TextEditingController();
  String translatedText = '';

  @override
  Widget build(BuildContext context) {
    return TextField(
      style: TextStyle(color: Colors.white),
      maxLines: 4,
      decoration: InputDecoration(
          filled: true,
          fillColor: Colors.grey[850],
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0)),
          hintText: 'Displayed Text',
          hintStyle: TextStyle(color: Colors.white)),
      controller: TextEditingController(text: translatedText),
    );
  }

  @override
  void dispose() {
    textController.dispose();
    super.dispose();
  }

  static void updateText(String text) {
    textController.text = text;
  }

  void updateTranslatedText(String text) {
    setState(() {
      translatedText = text;
    });
  }
}

class LanguageList extends StatefulWidget {
  @override
  _LanguageListState createState() => _LanguageListState();
}

class _LanguageListState extends State<LanguageList> {
  List<String> supportedLanguages = [];
  String selectedLanguage = '';

  String sourceLanguage = 'en';

  @override
  void initState() {
    super.initState();
    fetchSupportedLanguages();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> fetchSupportedLanguages() async {
    final host = 'google-translate1.p.rapidapi.com';
    final apiKey = '9b30f73df1msh0f34b59d3985612p183444jsn723b7a078434';

    final response = await http.get(
      Uri.parse(
          'https://google-translate1.p.rapidapi.com/language/translate/v2/languages'),
      headers: {
        'X-RapidAPI-Key': apiKey,
      },
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);

      if (data.containsKey('data') && data['data'].containsKey('languages')) {
        final List<dynamic> languages = data['data']['languages'];

        setState(() {
          supportedLanguages =
              languages.map((lang) => lang['language']).cast<String>().toList();
        });
      }
    }
  }

  void _showLanguageListModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: EdgeInsets.all(16.0),
          child: ListView.builder(
            itemCount: supportedLanguages.length,
            itemBuilder: (BuildContext context, int index) {
              return ListTile(
                title: Text(supportedLanguages[index]),
                onTap: () {
                  setState(() {
                    selectedLanguage = supportedLanguages[index];
                  });
                  Navigator.of(context).pop();
                },
              );
            },
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ButtonStyle(
        shape: MaterialStateProperty.all<RoundedRectangleBorder>(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
        backgroundColor:
            MaterialStateProperty.all<Color>(Colors.grey[850] ?? Colors.grey),
      ),
      onPressed: () {
        _showLanguageListModal(context);
      },
      child:
          Text(selectedLanguage.isNotEmpty ? '$selectedLanguage' : 'Language'),
    );
  }
}

Future<void> fetchTranslation(String q, String target, String source) async {
  final host = 'google-translate1.p.rapidapi.com';
  final apiKey = '9b30f73df1msh0f34b59d3985612p183444jsn723b7a078434';

  final response = await http.post(
    Uri.parse('https://google-translate1.p.rapidapi.com/language/translate/v2'),
    headers: {
      'Content-Type': 'application/json',
      'X-RapidAPI-Key': apiKey,
    },
    body: json.encode({
      'q': q,
      'target': target,
      'source': source,
    }),
  );

  if (response.statusCode == 200) {
    final Map<String, dynamic> data = json.decode(response.body);

    if (data.containsKey('data') && data['data'].containsKey('translations')) {
      final List<dynamic> translations = data['data']['translations'];

      if (translations.isNotEmpty) {
        final String translatedText = translations[0]['translatedText'];

        MySecondTextFieldState.updateText(translatedText);
      }
    }
  }
}
