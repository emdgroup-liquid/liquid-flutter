import 'package:flutter/material.dart';
import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class HomeSignInCard extends StatelessWidget {
  const HomeSignInCard({super.key});

  @override
  Widget build(BuildContext context) {
    return LdCard(
      child: LdAutoSpace(
        children: [
          LdText.h('Get Started'),
          LdInput(hint: 'Email', label: 'Email'),
          LdInput(hint: 'Password', label: 'Password'),
          LdCheckbox(checked: true, label: 'Keep me signed in'),
          LdButton(onPressed: () {}, width: double.infinity, child: Text('Sign in')),
          Align(
            alignment: Alignment.center,
            child: LdMute(
              child: LdText(
                "Don't have an account? [Sign up](https://example.com/signup)",
                processLinks: true,
                textAlign: TextAlign.center,
              ),
            ),
          ),
          LdDivider(),
          Align(
            alignment: Alignment.center,
            child: LdText.p('Or sign in with', textAlign: TextAlign.center),
          ),
          LdButton.outline(
            leading: Icon(LucideIcons.mail),
            onPressed: () {},
            width: double.infinity,
            alignment: MainAxisAlignment.center,
            child: Text('SSO'),
          ),
          LdButton.outline(
            leading: Icon(LucideIcons.computer),
            onPressed: () {},
            alignment: MainAxisAlignment.center,
            width: double.infinity,
            child: Text('Github'),
          ),
        ],
      ),
    );
  }
}
