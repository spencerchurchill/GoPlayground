import 'package:flutter/material.dart';

class AGP {
  static Widget aboutPlayground() {
    return new Center(
      child: new Card(
        margin: EdgeInsets.all(16.0),
        elevation: 8.0,
        child: new Padding(
          padding: const EdgeInsets.all(8.0),
          child: new RichText(
            text: TextSpan(
              text: 'About the Playground',
              style: TextStyle(fontWeight: FontWeight.bold),
              children: <TextSpan>[
                TextSpan(
                    text:
                        '\n\nThe Go Playground is a web service that runs on golang.org\'s servers. The service receives a Go program, vets, compiles, links, and runs the program inside a sandbox, then returns the output.\n\nIf the program contains tests or examples and no main function, the service runs the tests. Benchmarks will likely not be supported since the program runs in a sandboxed environment with limited resources.',
                    style: TextStyle(fontWeight: FontWeight.normal))
              ],
            ),
          ),
        ),
      ),
    );
  }
}
