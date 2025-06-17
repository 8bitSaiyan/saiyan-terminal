import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class WelcomeMessage {
  static const Widget widget = Text(
    r'''
    
            ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢰⣦⡀⠀⠀⠀⠀⠀⠀⠀
            ⠀⠀⠀⠀⠀⠀⠀⠠⠀⡀⠀⣠⡞⢀⣿⣿⣷⡀⠀⠀⠀⠀⠀⠀
            ⠀⠀⠀⠀⠀⠀⣴⡇⠠⢠⣾⣿⢃⣾⣿⣿⣿⣿⡄⠀⠀⠀⠀⠀
            ⠀⠀⠀⣼⡀⣼⣿⣇⣵⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣆⠀⠀⠀⠀
            ⠀⠀⢰⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡆⠀⡀⠀
            ⠀⢠⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡇⣴⠁⠀
            ⠀⣾⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡏⠀⡀
            ⡀⢹⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣡⣾⡇
            ⣿⣾⣿⣿⣿⣿⣿⠿⣿⣿⣿⣿⣿⣿⣿⠿⣿⣿⣿⣿⣿⢟⣴⠁
            ⠘⣿⣿⣿⣿⠫⠀⠀⠈⢿⣿⣿⣿⡟⠁⠀⠀⠙⣿⣿⣟⣾⡏⠀
            ⣀⠹⣿⣿⣿⠀⠀⠀⠀⠈⢿⣿⡟⠀⠀⠀⠀⠀⣿⣿⣯⡟⡠⠂
            ⠈⢿⡾⢝⢿⡀⠀⠀⠀⠀⠈⠿⠀⠀⠀⠀⠀⢀⣿⣋⢩⣾⡞⠀
            ⠀⠀⠱⢣⠋⠇⠿⣦⡀⠀⢀⠀⠀⠀⢀⣴⠾⢠⠓⡄⡜⠉⠀⠀
            ⠀⠀⠀⠀⠫⢙⡀⠠⣙⠦⣄⠀⣠⠴⢋⠄⠀⢦⡩⠊⠀⠀⠀⠀
            ⠀⠀⠀⠀⠀⠀⢧⡀⠀⠀⠈⢠⠀⠈⠀⠀⡈⠀⠀⠀⠀⠀⠀⠀
            ⠀⠀⠀⠀⠀⠀⠀⠀⠢⠀⠀⠚⠅⠀⡠⠊⠀⠀⠀⠀⠀⠀⠀⠀
            ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠤⠄⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
   ____  __    _ __  _____       _                 
  ( __ )/ /_  (_) /_/ ___/____ _(_)_  ______ _____ 
 / __  / __ \/ / __/\__ \/ __ `/ / / / / __ `/ __ \
/ /_/ / /_/ / / /_ ___/ / /_/ / / /_/ / /_/ / / / /
\____/_.___/_/\__//____/\__,_/_/\__, /\__,_/_/ /_/ 
                               /____/              

Welcome to my terminal portfolio.
Type "help" to see a list of available commands.
''',
    style: TextStyle(color: Color(0xFF00FF00)),
  );
}

class Help {
  static const Widget widget = Text(
    '''
Available Commands:
  ls          - list files and directories
  cat [file]  - display file content
  cd [dir]    - change directory
  pwd         - show current directory path
  clear       - clear the terminal screen
  whoami      - display user information
  date        - show the current date and time
  help        - display this help message
  tree        - show directory structure as a tree
  github      - open my GitHub profile
  sudo        - hmmm...
''',
    style: TextStyle(color: Color(0xFF00DD00)),
  );
}

class WhoAmI {
  static const String text = 'user: visitor\nname: 8bitSaiyan';
}

class Sudo {
  static const String text = '[sudo] password for visitor: \nSorry, try again.\n[sudo] password for visitor: \nIncorrect password\n[sudo] password for visitor: \nsudo: 3 incorrect password attempts';
}

class Coffee {
  static const Widget widget = Text(
    r'''
         {
      {   }
       }_{ __{
    .-{   }   }-.
   (   }     {   )
   |'-.._____..-'|
   |             ;--.
   |            (__  \
   |             | )  )
   |             |/  /
   |             /  /
   |            (  /
   \             y'
    '-.._____..-'
''',
    style: TextStyle(color: Colors.brown),
  );
}