import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iu_number_place_assistant/puzzle/assistant.dart';
import 'package:iu_number_place_assistant/puzzle/solver.dart';
import 'package:package_info_plus/package_info_plus.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  static const appName = 'Number Place Assistant';

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: appName,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color.fromARGB(255, 10, 158, 226),
        ),
        useMaterial3: true,
        textTheme: TextTheme(
          displayLarge: const TextStyle(
            fontSize: 72,
            fontWeight: FontWeight.bold,
          ),
          titleLarge: GoogleFonts.righteous(
            fontSize: 30,
          ),
          bodyMedium: GoogleFonts.firaSans(
            fontSize: 20,
          ),
          displaySmall: GoogleFonts.pacifico(
            fontSize: 16,
          ),
        ),
      ),
      home: const MyHomePage(title: appName),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  /// The number of row/column/blocks
  static const int _n9 = 9;

  final List<List<TextEditingController>> _controllers = List.generate(
      _n9, (index) => List.generate(9, (_) => TextEditingController()));
  final List<List<String>> _values =
      List.generate(_n9, (index) => List.generate(_n9, (_) => ''));
  final List<List<int>> _fixedValues =
      List.generate(_n9, (index) => List.generate(_n9, (_) => 0));
  final _formKey = GlobalKey<FormState>();

  final List<List<bool>> _hintCells =
      List.generate(_n9, (index) => List.generate(9, (i) => false));

  static List<List<int>>? _answer;

  List<Widget> _buildNumberPlace() {
    var widgets = <Widget>[];
    for (var i = 0; i < _n9; i++) {
      widgets.add(
        Container(
          decoration:
              BoxDecoration(border: Border.all(color: Colors.black, width: 1)),
          child: GridView.builder(
            itemCount: _n9,
            physics: const NeverScrollableScrollPhysics(),
            itemBuilder: (context, index) {
              return Container(
                decoration: BoxDecoration(
                    border: Border.all(width: 1, color: Colors.black)),
                child: Container(
                  decoration: _hintCells[i][index]
                      ? const BoxDecoration(
                          color: Color.fromARGB(97, 67, 195, 255))
                      : const BoxDecoration(color: Colors.white),
                  child: Center(
                    child: _fixedValues[i][index] == 0
                        ? TextFormField(
                            controller: _controllers[i][index],
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontSize: 18),
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly
                            ],
                            decoration: const InputDecoration(
                                isDense: true,
                                errorMaxLines: 1,
                                errorText: '',
                                errorStyle: TextStyle(
                                  color: Colors.black,
                                  fontSize: 0,
                                ),
                                hintText: "",
                                border: InputBorder.none),
                            onChanged: (value) {
                              _values[i][index] = value;
                            },
                            textInputAction: TextInputAction.next,
                            validator: (value) {
                              switch (value) {
                                case String s:
                                  if (s == '') return null;
                                  var n = int.tryParse(s);
                                  if (n == null || n <= 0 || 10 <= n) return '';
                                  return null;
                                default:
                                  return null;
                              }
                            },
                          )
                        : Text("${_fixedValues[i][index]}"),
                  ),
                ),
              );
            },
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3),
          ),
        ),
      );
    }
    return widgets;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
        actions: [
          IconButton(
            onPressed: () async {
              await PackageInfo.fromPlatform().then((info) => showLicensePage(
                    context: context,
                    applicationName: widget.title,
                    applicationVersion: info.version,
                    applicationIcon: const Icon(
                      Icons.biotech,
                      size: 40,
                    ),
//              applicationLegalese: '© 2024',
                  ));
            },
            icon: const Icon(Icons.info),
            tooltip: 'Licenses',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.only(top: 10.0, left: 5, right: 5),
        child: Center(
          child: Column(children: [
            Stack(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    ElevatedButton(
                      onPressed: () => showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Reset all numbers?'),
                          content: const SingleChildScrollView(
                            child: ListBody(
                              children: <Widget>[
                                Text('This action cannot undo.'),
                              ],
                            ),
                          ),
                          actions: <Widget>[
                            TextButton(
                              child: const Text('Cancel'),
                              onPressed: () =>
                                  Navigator.of(context).pop('Cancel'),
                            ),
                            TextButton(
                              child: const Text('Reset'),
                              onPressed: () {
                                // clear answer
                                _answer = null;

                                // clear views
                                for (var b = 0; b < _n9; b++) {
                                  for (var i = 0; i < _n9; i++) {
                                    _values[b][i] = '';
                                    _fixedValues[b][i] = 0;
                                    _controllers[b][i].clear();
                                  }
                                }
                                setState(() {});
                                Navigator.of(context).pop('Reset');
                              },
                            ),
                          ],
                        ),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.loop),
                          SizedBox(
                            width: 5,
                          ),
                          Text("Reset"),
                        ],
                      ),
                    ),
                  ],
                ),
                Align(
                  alignment: Alignment.bottomRight,
                  child: TextButton(
                    onPressed: () {
                      // validate
                      if (_formKey.currentState?.validate() != true) {
                        ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content:
                                    Text('Please input number from 1 to 9.')));
                        return;
                      }

                      // input
                      var list = _values
                          .map((element) =>
                              element.map((e) => int.tryParse(e) ?? 0).toList())
                          .toList();

                      // solve
                      var solver = PuzzleSolver(list);
                      var (:result, :puzzle) = solver.solve();

                      if (puzzle != null) {
                        for (var (ib, b) in puzzle.indexed) {
                          for (var (i, x) in b.indexed) {
                            _fixedValues[ib][i] = x;
                          }
                        }
                      }

                      _answer = puzzle;
                      setState(() {});

                      // show message
                      var message = switch (result) {
                        SolverResults.success => "Success",
                        SolverResults.invalid => "There is no answer.",
                        SolverResults.failed =>
                          "Sorry. I could't solve the puzzle."
                      };
                      final snackBar = SnackBar(
                        content: Text(message),
                        duration: const Duration(seconds: 5),
                      );
                      ScaffoldMessenger.of(context).showSnackBar(snackBar);
                    },
                    child: const Text("Show answer"),
                  ),
                ),
              ],
            ),
            const SizedBox(
              height: 5,
            ),
            Expanded(
              child: Form(
                key: _formKey,
                child: GridView.count(
                  crossAxisCount: 3,
                  mainAxisSpacing: 0,
                  crossAxisSpacing: 0,
                  children: _buildNumberPlace(),
                ),
              ),
            ),
          ]),
        ),
      ),
      floatingActionButton: Stack(children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            FloatingActionButton(
              onPressed: () {
                // validate
                if (_formKey.currentState?.validate() != true) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content: Text('Please input number from 1 to 9.')));
                  return;
                }

                // clear
                for (var b = 0; b < _n9; b++) {
                  for (var i = 0; i < _n9; i++) {
                    _hintCells[b][i] = false;
                  }
                }

                // input
                var list = _values
                    .map((element) =>
                        element.map((e) => int.tryParse(e) ?? 0).toList())
                    .toList();

                if (_answer != null) {
                  // compare
                } else {
                  // solve
                  var solver = PuzzleSolver(list);
                  var (:result, :puzzle) = solver.solve();
                  _answer = puzzle;

                  if (result != SolverResults.success) {
                    // show message
                    var message = switch (result) {
                      SolverResults.invalid =>
                        " I don't have any hints because there is no answer.",
                      SolverResults.failed =>
                        "Sorry. I don't have any hints because I could't solve the puzzle.",
                      _ => ''
                    };
                    final snackBar = SnackBar(
                      content: Text(message),
                      duration: const Duration(seconds: 5),
                    );
                    ScaffoldMessenger.of(context).showSnackBar(snackBar);
                    return;
                  }
                }

                // ask hint
                var helper = PuzzleAssistant(list);
                var hint = helper.getHint();
                if (hint == null) {
                  const snackBar = SnackBar(
                    content: Text("Something happend"),
                    duration: Duration(seconds: 5),
                  );
                  ScaffoldMessenger.of(context).showSnackBar(snackBar);
                  return;
                }

                for (var (b, i) in hint.positions) {
                  _hintCells[b][i] = true;
                }

                final snackBar = SnackBar(
                  content: Text("${hint.numbers.first} is in the blue area"),
                  duration: const Duration(seconds: 5),
                );
                ScaffoldMessenger.of(context).showSnackBar(snackBar);

                debugPrint(hint.toString());

                setState(() {});
              },
              tooltip: "Hint",
              child: const Icon(Icons.lightbulb),
            ),
          ],
        ),
      ]),
    );
  }
}
