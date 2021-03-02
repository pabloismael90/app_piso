import 'package:app_piso/src/pages/home_page.dart';
import 'package:app_piso/src/pages/finca/finca_form.dart';
import 'package:app_piso/src/pages/finca/finca_page.dart';
import 'package:app_piso/src/pages/parcelas/parcela_form.dart';
import 'package:app_piso/src/pages/parcelas/parcelas_page.dart';
import 'package:app_piso/src/pages/testPiso/testPiso_form.dart';
import 'package:app_piso/src/pages/testPiso/testPiso_page.dart';
import 'package:app_piso/src/utils/constants.dart';


import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';


void main() => runApp(MyApp());
 
class MyApp extends StatelessWidget {
    @override
    Widget build(BuildContext context) {

        SystemChrome.setPreferredOrientations([
            DeviceOrientation.portraitUp,
            DeviceOrientation.portraitDown,
        ]);
        SystemChrome.setSystemUIOverlayStyle(
            SystemUiOverlayStyle(
                statusBarColor: Colors.transparent,
                statusBarIconBrightness: Brightness.light, 
            )        
        );


        return MaterialApp(
            debugShowCheckedModeBanner: false,
            
            localizationsDelegates: [
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: [
                const Locale('es', 'ES'),
                // const Locale('en', 'US'),
            ],
            title: 'Material App',
            initialRoute:'home',
            routes: {
                'home' : ( BuildContext context ) => HomePage(),
                //Finca
                'fincas' : ( BuildContext context ) => FincasPage(),
                'addFinca' : ( BuildContext context ) => AgregarFinca(),
                //Parcelas
                'parcelas' : ( BuildContext context ) => ParcelaPage(),
                'addParcela' : ( BuildContext context ) => AgregarParcela(),
                //test
                'tests' :  ( BuildContext context ) => TestPage(),
                'addTest' : ( BuildContext context ) => AgregarTest(),
                
                

            },
            theme: ThemeData(
                fontFamily: "Museo",
                scaffoldBackgroundColor: kBackgroundColor,
                textTheme: Theme.of(context).textTheme.apply(displayColor: kTextColor, fontFamily: 'Museo'),
                appBarTheme: AppBarTheme(color: kbase,brightness: Brightness.dark),
                primaryColor:kbase,
                primaryIconTheme: IconThemeData(color: Colors.white),
                inputDecorationTheme: InputDecorationTheme(
                    labelStyle: Theme.of(context).textTheme
                                .headline6
                                .copyWith(fontWeight: FontWeight.bold, color: kTextColor, fontSize: 18, fontFamily: 'Museo'),
                ),
            
                buttonTheme: ButtonThemeData(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.0),
                    ),
                    textTheme: ButtonTextTheme.primary,
                    buttonColor: Color(0xFF3f2a56),
                   
                )
                
            ),
        );
    }
}
