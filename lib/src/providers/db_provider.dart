import 'dart:io';

import 'package:app_piso/src/models/acciones_model.dart';
import 'package:app_piso/src/models/decisiones_model.dart';
import 'package:app_piso/src/models/existePlaga_model.dart';
import 'package:app_piso/src/models/planta_model.dart';
import 'package:app_piso/src/models/testplaga_model.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';


import 'package:app_piso/src/models/finca_model.dart';
export 'package:app_piso/src/models/finca_model.dart';
import 'package:app_piso/src/models/parcela_model.dart';
export 'package:app_piso/src/models/parcela_model.dart';

class DBProvider {

    static Database _database; 
    static final DBProvider db = DBProvider._();

    DBProvider._();

    Future<Database> get database async {

        if ( _database != null ) return _database;

        _database = await initDB();
        return _database;
    }

    initDB() async {

        Directory documentsDirectory = await getApplicationDocumentsDirectory();

        final path = join( documentsDirectory.path, 'apppiso.db' );

        print(path);

        return await openDatabase(
            path,
            version: 1,
            onOpen: (db) {},
            onConfigure: _onConfigure,
            onCreate: ( Database db, int version ) async {
                await db.execute(
                    'CREATE TABLE Finca ('
                    ' id TEXT PRIMARY KEY,'
                    ' nombreFinca TEXT,'
                    ' areaFinca REAL,'
                    ' tipoMedida INTEGER,'
                    ' nombreProductor TEXT,'
                    ' nombreTecnico TEXT'
                    ')'
                );

                await db.execute(
                    'CREATE TABLE Parcela ('
                    ' id TEXT PRIMARY KEY,'
                    ' idFinca TEXT,'
                    ' nombreLote TEXT,'
                    ' areaLote REAL,'
                    ' variedadCacao INTEGER,'
                    ' numeroPlanta INTEGER,'
                    'CONSTRAINT fk_parcela FOREIGN KEY(idFinca) REFERENCES Finca(id) ON DELETE CASCADE'
                    ')'
                );

                await db.execute(
                    'CREATE TABLE TestPiso ('
                    ' id TEXT PRIMARY KEY,'
                    ' idFinca TEXT,'
                    ' idLote TEXT,'
                    ' fechaTest TEXT,'
                    ' caminatas INTEGER,'
                    ' CONSTRAINT fk_fincaTest FOREIGN KEY(idFinca) REFERENCES Finca(id) ON DELETE CASCADE,'
                    ' CONSTRAINT fk_parcelaTest FOREIGN KEY(idLote) REFERENCES Parcela(id) ON DELETE CASCADE'
                    ')'
                );

                await db.execute(
                    'CREATE TABLE Paso ('
                    'id TEXT PRIMARY KEY,'
                    ' idTest TEXT,'
                    ' caminata INTEGER,'
                    ' CONSTRAINT fk_testPiso FOREIGN KEY(idTest) REFERENCES TestPiso(id) ON DELETE CASCADE'
                    ')'
                );

                await db.execute(
                    'CREATE TABLE EnContacto ('
                    'id TEXT PRIMARY KEY,'
                    ' idPaso INTEGER,'
                    ' idContacto INTEGER,'
                    ' existe INTEGER,'
                    ' CONSTRAINT fk_existeContacto FOREIGN KEY(idPaso) REFERENCES Paso(id) ON DELETE CASCADE'
                    ')'
                );


                await db.execute(
                    'CREATE TABLE Decisiones ('
                    'id TEXT PRIMARY KEY,'
                    ' idTest TEXT,'
                    ' idPregunta INTEGER,'
                    ' idItem INTEGER,'
                    ' repuesta INTEGER,'
                    ' CONSTRAINT fk_decisiones FOREIGN KEY(idTest) REFERENCES TestPiso(id) ON DELETE CASCADE'
                    ')'
                );

                await db.execute(
                    'CREATE TABLE Acciones ('
                    'id TEXT PRIMARY KEY,'
                    ' idTest TEXT,'
                    ' idItem INTEGER,'
                    ' repuesta TEXT,'
                    ' CONSTRAINT fk_acciones FOREIGN KEY(idTest) REFERENCES TestPiso(id) ON DELETE CASCADE'
                    ')'
                );
            }
        
        );

    }

    static Future _onConfigure(Database db) async {
        await db.execute('PRAGMA foreign_keys = ON');
    }

    

    //ingresar Registros
    nuevoFinca( Finca nuevaFinca ) async {
        final db  = await database;
        final res = await db.insert('Finca',  nuevaFinca.toJson() );
        return res;
    }

    nuevoParcela( Parcela nuevaParcela ) async {
        final db  = await database;
        final res = await db.insert('Parcela',  nuevaParcela.toJson() );
        return res;
    }

    nuevoTestPlaga( TestPiso nuevaTestPiso ) async {
        final db  = await database;
        final res = await db.insert('TestPlaga',  nuevaTestPiso.toJson() );
        return res;
    }

    nuevoPlanta( Planta nuevaPlanta ) async {
        final db  = await database;
        final res = await db.insert('Planta',  nuevaPlanta.toJson() );
        return res;
    }

    nuevoExistePlagas( ExistePlaga existePlaga ) async {
        final db  = await database;
        final res = await db.insert('ExistePlaga',  existePlaga.toJson() );
        return res;
    }

    nuevaDecision( Decisiones decisiones ) async {
        final db  = await database;
        final res = await db.insert('Decisiones',  decisiones.toJson() );
        return res;
    }

    nuevaAccion( Acciones acciones ) async {
        final db  = await database;
        final res = await db.insert('Acciones',  acciones.toJson() );
        return res;
    }

    
    
    //Obtener registros
    Future<List<Finca>> getTodasFincas() async {

        final db  = await database;
        final res = await db.query('Finca');

        List<Finca> list = res.isNotEmpty 
                                ? res.map( (c) => Finca.fromJson(c) ).toList()
                                : [];
        return list;
    }

    Future<List<Parcela>> getTodasParcelas() async {

        final db  = await database;
        final res = await db.query('Parcela');

        List<Parcela> list = res.isNotEmpty 
                                ? res.map( (c) => Parcela.fromJson(c) ).toList()
                                : [];
        return list;
    }

    Future<List<TestPiso>> getTodasTestPlaga() async {

        final db  = await database;
        final res = await db.query('TestPlaga');

        List<TestPiso> list = res.isNotEmpty 
                                ? res.map( (c) => TestPiso.fromJson(c) ).toList()
                                : [];
        return list;
    }

    Future<List<Planta>> getTodasPlantas() async {

        final db  = await database;
        final res = await db.query('Planta');

        List<Planta> list = res.isNotEmpty 
                                ? res.map( (c) => Planta.fromJson(c) ).toList()
                                : [];
        return list;
    }

    Future<int> countPlanta(String idTest,  int estacion ) async {

        final db = await database;
        int count = Sqflite.firstIntValue(await db.rawQuery("SELECT COUNT(*) FROM Planta WHERE idTest = '$idTest' AND estacion = '$estacion'"));
        return count;
    

    }

    Future<List<Decisiones>> getTodasDesiciones() async {

        final db  = await database;
        final res = await db.query('Decisiones');

        List<Decisiones> list = res.isNotEmpty 
                                ? res.map( (c) => Decisiones.fromJson(c) ).toList()
                                : [];
        return list;
    }

    Future<List<Acciones>> getTodasAcciones() async {

        final db  = await database;
        final res = await db.rawQuery('SELECT DISTINCT idTest FROM Acciones');

        List<Acciones> list = res.isNotEmpty 
                                ? res.map( (c) => Acciones.fromJson(c) ).toList()
                                : [];

        
        return list;
    }
    
    
    //REgistros por id
    Future<Finca> getFincaId(String id) async{
        final db = await database;
        final res = await db.query('Finca', where: 'id = ?', whereArgs: [id]);
        return res.isNotEmpty ? Finca.fromJson(res.first) : null;
    }

    Future<Parcela> getParcelaId(String id) async{
        final db = await database;
        final res = await db.query('Parcela', where: 'id = ?', whereArgs: [id]);
        return res.isNotEmpty ? Parcela.fromJson(res.first) : null;
    }

    Future<TestPiso> getTestId(String id) async{
        final db = await database;
        final res = await db.query('Testplaga', where: 'id = ?', whereArgs: [id]);
        return res.isNotEmpty ? TestPiso.fromJson(res.first) : null;
    }

    Future<List<Parcela>> getTodasParcelasIdFinca(String idFinca) async{

        final db = await database;
        final res = await db.query('Parcela', where: 'idFinca = ?', whereArgs: [idFinca]);
        List<Parcela> list = res.isNotEmpty 
                    ? res.map( (c) => Parcela.fromJson(c) ).toList() 
                    : [];
        
        return list;            
    }

    Future<List<Planta>> getTodasPlantaIdTest(String idTest) async{
        final db = await database;
        final res = await db.query('Planta', where: 'idTest = ?', whereArgs: [idTest]);
        List<Planta> list = res.isNotEmpty 
                    ? res.map( (c) => Planta.fromJson(c) ).toList() 
                    : [];
        return list;            
    }
   
    Future<List<Planta>> getTodasPlantasIdTest(String idTest, int estacion) async{
        final db = await database;
        final res = await db.rawQuery("SELECT * FROM Planta WHERE idTest = '$idTest' AND estacion = '$estacion'");
        //final res = await db.query('Planta', where: 'idTest = ?', whereArgs: [idTest]);
        List<Planta> list = res.isNotEmpty 
                    ? res.map( (c) => Planta.fromJson(c) ).toList() 
                    : [];

        return list;           
    }

    Future<List<ExistePlaga>> getTodasPlagasIdPlanta(String idPlanta) async {

        final db  = await database;
        final res = await db.rawQuery("SELECT * FROM ExistePlaga WHERE idPlanta = '$idPlanta'");

        List<ExistePlaga> list = res.isNotEmpty 
                    ? res.map( (c) => ExistePlaga.fromJson(c) ).toList() 
                    : [];
        //print(list);
        return list;
    }

    Future<int> getPlagasIdPlanta(String idPlanta, int idplaga) async {
        
        final db  = await database;
        String query = "SELECT existe FROM ExistePlaga WHERE idPlanta = '$idPlanta' AND idPlaga = '$idplaga'";
        final  res = await db.rawQuery(query);
        int value = res.isNotEmpty ? res[0]['existe'] : -1;
        //print(value);

        return value;
    }

    Future<List<Decisiones>> getDecisionesIdTest(String idTest) async{
        final db = await database;
        final res = await db.query('Decisiones', where: 'idTest = ?', whereArgs: [idTest]);
        List<Decisiones> list = res.isNotEmpty 
                                ? res.map( (c) => Decisiones.fromJson(c) ).toList()
                                : [];
        return list;
    }

    Future<List<Acciones>> getAccionesIdTest(String idTest) async{
        final db = await database;
        final res = await db.query('Acciones', where: 'idTest = ?', whereArgs: [idTest]);
        List<Acciones> list = res.isNotEmpty 
                                ? res.map( (c) => Acciones.fromJson(c) ).toList()
                                : [];
        return list;
    }


    //List Select
    Future<List<Map<String, dynamic>>> getSelectFinca() async {
       
        final db  = await database;
        final res = await db.rawQuery(
            "SELECT id AS value, nombreFinca AS label FROM Finca"
        );
        List<Map<String, dynamic>> list = res.isNotEmpty ? res : [];

        //print(list);

        return list; 
    }
    
    Future<List<Map<String, dynamic>>> getSelectParcelasIdFinca(String idFinca) async{
        final db = await database;
        final res = await db.rawQuery(
            "SELECT id AS value, nombreLote AS label FROM Parcela WHERE idFinca = '$idFinca'"
        );
        List<Map<String, dynamic>> list = res.isNotEmpty ? res : [];

        return list;
                    
    }


    // Actualizar Registros
    Future<int> updateFinca( Finca nuevaFinca ) async {

        final db  = await database;
        final res = await db.update('Finca', nuevaFinca.toJson(), where: 'id = ?', whereArgs: [nuevaFinca.id] );
        return res;

    }

    Future<int> updateParcela( Parcela nuevaParcela ) async {

        final db  = await database;
        final res = await db.update('Parcela', nuevaParcela.toJson(), where: 'id = ?', whereArgs: [nuevaParcela.id] );
        return res;

    }

    Future<int> updateTestPlaga( TestPiso nuevoTestPiso ) async {

        final db  = await database;
        final res = await db.update('TestPlaga', nuevoTestPiso.toJson(), where: 'id = ?', whereArgs: [nuevoTestPiso.id] );
        return res;

    }


    //Conteos analisis
    Future<double> countPlagaEstacion( String idTest, int estacion, int idPlaga) async {

        final db = await database;
        String query =  "SELECT COUNT(*) FROM TestPlaga "+
                        "INNER JOIN Planta ON TestPlaga.id = Planta.idTest " +
                        "INNER JOIN ExistePlaga ON  Planta.id = ExistePlaga.idPlanta " +
                        "WHERE idTest = '$idTest' AND estacion = '$estacion' AND idPlaga = '$idPlaga' AND existe = 1";
        int res = Sqflite.firstIntValue(await db.rawQuery(query));
        double value = res/10;
        return value;

    }

    Future<double> countPlagaTotal( String idTest, int idPlaga) async {

        final db = await database;
        String query =  "SELECT COUNT(*) FROM TestPlaga "+
                        "INNER JOIN Planta ON TestPlaga.id = Planta.idTest " +
                        "INNER JOIN ExistePlaga ON  Planta.id = ExistePlaga.idPlanta " +
                        "WHERE idTest = '$idTest' AND idPlaga = '$idPlaga' AND existe = 1";
        int res = Sqflite.firstIntValue(await db.rawQuery(query));
        double value = res/30;
        return value;

    }

    Future<double> countDeficiencia( String idTest, int estacion) async {

        final db = await database;
        String query =  "SELECT COUNT(*) FROM Planta WHERE idTest = '$idTest' AND estacion = '$estacion' AND deficiencia = 1";
        int res = Sqflite.firstIntValue(await db.rawQuery(query));
        double value = res/10;
        return value;

    }

    Future<double> countTotalDeficiencia( String idTest ) async {

        final db = await database;
        String query =  "SELECT COUNT(*) FROM Planta WHERE idTest = '$idTest' AND deficiencia = 1";
        int res = Sqflite.firstIntValue(await db.rawQuery(query));
        double value = res/30;
        return value;

    }

    Future<double> countProduccion( String idTest, int estacion, int estado) async {

        final db = await database;
        String query =  "SELECT COUNT(*) FROM Planta WHERE idTest = '$idTest' AND estacion = '$estacion' AND produccion = '$estado'";
        int res = Sqflite.firstIntValue(await db.rawQuery(query));
        double value = res/10;
        return value;

    }

    Future<double> countTotalProduccion( String idTest, int estado ) async {

        final db = await database;
        String query =  "SELECT COUNT(*) FROM Planta WHERE idTest = '$idTest' AND produccion = '$estado'";
        int res = Sqflite.firstIntValue(await db.rawQuery(query));
        double value = res/30;
        return value;

    }

    // Eliminar registros
    Future<int> deleteFinca( String idFinca ) async {

        final db  = await database;
        final res = await db.delete('Finca', where: 'id = ?', whereArgs: [idFinca]);
        return res;
    }
    Future<int> deleteParcela( String idParcela ) async {

        final db  = await database;
        final res = await db.delete('Parcela', where: 'id = ?', whereArgs: [idParcela]);
        return res;
    }

    Future<int> deleteTestPlaga( String idTest ) async {

        final db  = await database;
        final res = await db.delete('TestPlaga', where: 'id = ?', whereArgs: [idTest]);
        return res;
    }

    Future<int> deletePlanta( String idPlanta ) async {

        final db  = await database;
        final res = await db.delete('Planta', where: 'id = ?', whereArgs: [idPlanta]);
        return res;
    }


}