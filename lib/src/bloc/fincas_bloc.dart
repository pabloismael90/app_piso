
import 'dart:async';

import 'package:app_piso/src/models/decisiones_model.dart';
import 'package:app_piso/src/models/paso_model.dart';
import 'package:app_piso/src/models/testPiso_model.dart';
import 'package:app_piso/src/providers/db_provider.dart';

class FincasBloc {

    static final FincasBloc _singleton = new FincasBloc._internal();

    factory FincasBloc() {
        return _singleton;
        
    }

    FincasBloc._internal() {
        obtenerFincas();
        obtenerParcelas();
    }
    
    final _fincasController = StreamController<List<Finca>>.broadcast();
    final _parcelasController = StreamController<List<Parcela>>.broadcast();
    final _pisoController = StreamController<List<TestPiso>>.broadcast();
    final _pasoController = StreamController<List<Paso>>.broadcast();
    final _countPasoControl = StreamController<List<Paso>>.broadcast();
    final _decisionesControl = StreamController<List<Decisiones>>.broadcast();
    

    final _fincasSelectControl = StreamController<List<Map<String, dynamic>>>.broadcast();
    final _parcelaSelectControl = StreamController<List<Map<String, dynamic>>>.broadcast();

    Stream<List<Finca>> get fincaStream => _fincasController.stream;
    Stream<List<Parcela>> get parcelaStream => _parcelasController.stream;
    Stream<List<TestPiso>> get pisoStream => _pisoController.stream;
    Stream<List<Paso>> get pasoStream => _pasoController.stream;
    Stream<List<Paso>> get countPaso => _countPasoControl.stream;
    Stream<List<Decisiones>> get decisionesStream => _decisionesControl.stream;


    Stream<List<Map<String, dynamic>>> get fincaSelect => _fincasSelectControl.stream;
    Stream<List<Map<String, dynamic>>> get parcelaSelect => _parcelaSelectControl.stream;

    
    //fincas
    obtenerFincas() async {
        _fincasController.sink.add( await DBProvider.db.getTodasFincas() );
    }

    addFinca( Finca finca ) async{
        await DBProvider.db.nuevoFinca(finca);
        obtenerFincas();
    }

    actualizarFinca( Finca finca ) async{
        await DBProvider.db.updateFinca(finca);
        obtenerFincas();
    }

    borrarFinca( String id ) async {
        await DBProvider.db.deleteFinca(id);
        obtenerFincas();
    }

    selectFinca() async{
        _fincasSelectControl.sink.add( await DBProvider.db.getSelectFinca());
    }
    

    //Parcelas
    obtenerParcelas() async {
        _parcelasController.sink.add( await DBProvider.db.getTodasParcelas() );
    }
    
    obtenerParcelasIdFinca(String idFinca) async {
        _parcelasController.sink.add( await DBProvider.db.getTodasParcelasIdFinca(idFinca) );
    }

    addParcela( Parcela parcela, String idFinca ) async{
        await DBProvider.db.nuevoParcela(parcela);
        obtenerParcelasIdFinca(idFinca);
    }

    actualizarParcela( Parcela parcela, String idFinca ) async{
        await DBProvider.db.updateParcela(parcela);
        obtenerParcelasIdFinca(idFinca);
    }
    
    borrarParcela( String id ) async {
        await DBProvider.db.deleteParcela(id);
        obtenerParcelas();
    }

    selectParcela(String idFinca) async{
        _parcelaSelectControl.sink.add( await DBProvider.db.getSelectParcelasIdFinca(idFinca));
    }

    //pisos
    obtenerPisos() async {
        _pisoController.sink.add( await DBProvider.db.getTodasTestPiso() );
    }
    
    addPiso( TestPiso nuevoTestPiso) async{
        await DBProvider.db.nuevoTestPiso(nuevoTestPiso);
        obtenerPisos();
        //obtenerParcelasIdFinca(idFinca);
    }

    borrarTestPiso( String idTest) async{
        await DBProvider.db.deleteTestPiso(idTest);
        obtenerPisos();
    }


    //Pasos
    obtenerPasos(String idTest) async {
        _countPasoControl.sink.add( await DBProvider.db.getTodasPasoIdTest(idTest) );  
    }

    
    obtenerPasoIdTest(String idTest, int estacion) async {
        _pasoController.sink.add( await DBProvider.db.getTodasPasosIdTest(idTest, estacion));
    }
    
    addPlata( Paso nuevaPaso, String idTest, int estacion) async{
        await DBProvider.db.nuevoPaso(nuevaPaso);
        obtenerPasoIdTest(idTest, estacion);
        obtenerPasos(idTest);
    }

    borrarPaso( Paso paso) async{
        await DBProvider.db.deletePaso(paso.id);
        obtenerPasoIdTest(paso.idTest, paso.caminata);
        obtenerPasos(paso.idTest);
    }


    //deciones
    obtenerDecisiones(String idTest) async {
        _decisionesControl.sink.add( await DBProvider.db.getDecisionesIdTest(idTest) );
    }


    


    //Cerrar stream
    dispose() {
        _fincasController?.close();
        _parcelasController?.close();
        _fincasSelectControl?.close();
        _parcelaSelectControl?.close();
        _pisoController?.close();
        _pasoController?.close();
        _countPasoControl?.close();
        _decisionesControl?.close();
    }

    

//   borrarScanTODOS() async {
    
//     await DBProvider.db.deleteAll();
//     obtenerScans();
//   }


}