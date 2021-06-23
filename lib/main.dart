import 'dart:ffi';
import 'dart:io';

import 'package:ffi/ffi.dart';
import 'package:flutter/material.dart';

late DynamicLibrary walletCoreLib;

void main() {
  walletCoreLib = Platform.isAndroid ? DynamicLibrary.open("libTrustWalletCore.so") : DynamicLibrary.process();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String _address = "empty";

  void genAddress() {
    try {
      final Pointer Function(Pointer<Utf8> bytes) twStringCreateWithUTF8Bytes =
          walletCoreLib.lookup<NativeFunction<Pointer Function(Pointer<Utf8>)>>('TWStringCreateWithUTF8Bytes').asFunction();

      final Pointer<Utf8> Function(Pointer bytes) twStringUTF8Bytes = walletCoreLib.lookup<NativeFunction<Pointer<Utf8> Function(Pointer)>>('TWStringUTF8Bytes').asFunction();
      final Pointer Function(int x, Pointer y) tWHDWalletCreate = walletCoreLib.lookup<NativeFunction<Pointer Function(Int32, Pointer)>>("TWHDWalletCreate").asFunction();

      final wallet = tWHDWalletCreate(128, twStringCreateWithUTF8Bytes("".toNativeUtf8()));
      final Pointer Function(Pointer x, int y) getAddress = walletCoreLib.lookup<NativeFunction<Pointer Function(Pointer, Int32)>>("TWHDWalletGetAddressForCoin").asFunction();

      final ethAddress = getAddress(wallet, 60); //ETH address

      _address = twStringUTF8Bytes(ethAddress).toDartString();
    } catch (e) {


    }
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("wallet core test"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              '$_address',
              style: Theme.of(context).textTheme.headline4,
            ),
            ElevatedButton(
                onPressed: () {
                  genAddress();
                  setState(() {});
                },
                child: Text("click to gen address"))
          ],
        ),
      ),
    );
  }
}
