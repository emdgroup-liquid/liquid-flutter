import 'package:flutter/material.dart';
import 'package:liquid/components/component_page.dart';
import 'package:liquid/components/component_well.dart';
import 'package:liquid_flutter/liquid_flutter.dart';

class MaterialDocumentation extends StatelessWidget {
  const MaterialDocumentation({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ComponentPage(
      title: "Material Components",
      demo: ComponentWell(
        child: LdAutoSpace(
          children: [
            const Text("Material Components"),
            ldSpacerM,
            ElevatedButton(
                onPressed: () {}, child: const Text("Elevated Button")),
            TextButton(onPressed: () {}, child: const Text("Text Button")),
            OutlinedButton(
                onPressed: () {}, child: const Text("Outlined Button")),
            FloatingActionButton(
                onPressed: () {}, child: const Icon(Icons.add)),
            IconButton(onPressed: () {}, icon: const Icon(Icons.add)),
            const TextField(
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Username',
              ),
            ),
            const TextField(
              obscureText: true,
              decoration: InputDecoration(
                label: Text("Password"),
              ),
            ),
            ldSpacerM,
            SegmentedButton(onSelectionChanged: (p0) {}, selected: const {
              "one"
            }, segments: const [
              ButtonSegment(
                label: Text("One"),
                value: "one",
              ),
              ButtonSegment(label: Text("Two"), value: "two"),
              ButtonSegment(label: Text("Three"), value: "three")
            ]),
            const LinearProgressIndicator(),
            const CircularProgressIndicator(),
            const Card(
              child: SizedBox(
                width: 200,
                height: 200,
              ),
            ),
            Checkbox(value: false, onChanged: (v) {}),
            Checkbox(value: true, onChanged: (v) {}),
            Radio(value: true, groupValue: true, onChanged: (v) {}),
            Radio(value: false, groupValue: true, onChanged: (v) {}),
            Switch(value: true, onChanged: (v) {}),
            Switch(value: false, onChanged: (v) {}),
          ],
        ),
      ),
    );
  }
}
