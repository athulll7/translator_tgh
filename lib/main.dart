import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('Home Page'),
        ),
        body: LanguageList(),
      ),
    );
  }
}

class LanguageList extends StatefulWidget {
  @override
  _LanguageListState createState() => _LanguageListState();
}

class _LanguageListState extends State<LanguageList> {
  List<String> supportedLanguages = [];

  @override
  void initState() {
    super.initState();
    fetchSupportedLanguages();
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

      print('API Response Data: $data');

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
    return Scaffold(
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            _showLanguageListModal(context);
          },
          child: Text('Show Supported Languages List'),
        ),
      ),
    );
  }
}
