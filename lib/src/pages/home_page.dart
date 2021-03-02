import 'dart:io';
import 'dart:typed_data';
import 'package:flutter_full_pdf_viewer/full_pdf_viewer_scaffold.dart';
import 'package:path_provider/path_provider.dart';

import 'package:app_piso/src/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:app_piso/src/utils/widget/category_cart.dart';


const String _documentPath = 'assets/documentos/prueba.pdf';

class HomePage extends StatelessWidget {
  const HomePage({Key key}) : super(key: key);




    @override
    Widget build(BuildContext context) {
        
        Size size = MediaQuery.of(context).size;
        Future<String> prepareTestPdf() async {
            final ByteData bytes =
                await DefaultAssetBundle.of(context).load(_documentPath);
            final Uint8List list = bytes.buffer.asUint8List();

            final tempDir = await getTemporaryDirectory();
            final tempDocumentPath = '${tempDir.path}/$_documentPath';

            final file = await File(tempDocumentPath).create(recursive: true);
            file.writeAsBytesSync(list);
            return tempDocumentPath;
        }

        return Scaffold(
            body: Column(
                children: [
                    Expanded(
                        child: Stack(
                            children:<Widget> [
                                Container(
                                    height: size.height * 0.25,
                                    decoration: BoxDecoration(
                                        color: kBackgroundColor,
                                        image: DecorationImage(
                                            image: AssetImage("assets/images/cacao_bg.png"),
                                            fit: BoxFit.fitWidth
                                        )
                                    ),
                                        
                                ),
                                Padding(
                                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 50),
                                    child: Text(
                                        "Plaga y enfermedades\nde Cacao",
                                        style: Theme.of(context).textTheme
                                            .headline4
                                            .copyWith(fontWeight: FontWeight.w900, fontSize: 30)
                                    ),
                                ),
                                Padding(
                                    padding: EdgeInsets.symmetric(horizontal: 20),
                                    child: Column(
                                        children: [
                                            SizedBox(height: size.height * 0.18),
                                            Expanded(
                                                child:GridView.count(
                                                        crossAxisCount: 2,
                                                        crossAxisSpacing: 30,
                                                        mainAxisSpacing:15,
                                                        children: <Widget>[
                                                            CategoryCard(
                                                                title: "Mis Fincas y mis parcelas",
                                                                svgSrc: "assets/icons/finca.svg",
                                                                press:() => Navigator.pushNamed(context, 'fincas' ),
                                                            ),
                                                            CategoryCard(
                                                                title: "Tomar datos y decisiones",
                                                                svgSrc: "assets/icons/test.svg",
                                                                press: () => Navigator.pushNamed(context, 'tests' ),
                                                            ),
                                                            CategoryCard(
                                                                title: "Consultar registro",
                                                                svgSrc: "assets/icons/report.svg",
                                                                press: () => Navigator.pushNamed(context, 'registros' ),
                                                            ),
                                                            CategoryCard(
                                                                title: "Imágenes",
                                                                svgSrc: "assets/icons/galeria.svg",
                                                                press: () => Navigator.pushNamed(context, 'galeria' ),
                                                            ),
                                                            CategoryCard(
                                                                title: "Instructivo",
                                                                svgSrc: "assets/icons/manual.svg",
                                                                press: () {
                                                                    prepareTestPdf().then((path) {
                                                                        Navigator.push(
                                                                            context,
                                                                            FadeRoute(
                                                                                page:FullPdfViewerScreen(path)),
                                                                        );
                                                                    });
                                                                },
                                                            ),
                                                            
                                                            
                                                        ],
                                                ),
                                                
                                            
                                            ),
                                        
                                        ],
                                    ),
                                ),
                                
                                            
                            ],
                        ),
                    ),
                    Container(
                        color: Colors.white,
                        child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 20),
                            child: Container(
                                height: size.height * 0.08,
                                decoration: BoxDecoration(
                                    color: Colors.white,
                                    image: DecorationImage(
                                        image: AssetImage("assets/images/logos.png"),
                                        fit: BoxFit.fitWidth
                                    )
                                ),
                                    
                            ),
                        ),
                    ),
                ],
            ),

        );
    }
   
}

class FullPdfViewerScreen extends StatelessWidget {
    final String pdfPath;

    FullPdfViewerScreen(this.pdfPath);

    @override
    Widget build(BuildContext context) {
        return PDFViewerScaffold(
            appBar: AppBar(
                title: Text("Manual", style: TextStyle(color: Colors.white),),
            ),
            path: pdfPath
        );
    }
}


class FadeRoute extends PageRouteBuilder {
  final Widget page;
  FadeRoute({this.page})
      : super(
          pageBuilder: (
            BuildContext context,
            Animation<double> animation,
            Animation<double> secondaryAnimation,
          ) =>
              page,
              transitionDuration: Duration(milliseconds: 100),
          transitionsBuilder: (
            BuildContext context,
            Animation<double> animation,
            Animation<double> secondaryAnimation,
            Widget child,
          ) =>
              FadeTransition(
                opacity: animation,
                child: child,
              ),
        );
}





