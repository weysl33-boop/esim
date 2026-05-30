import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:esim/core/helper/string_format_helper.dart';
import 'package:esim/core/utils/my_strings.dart';
import 'package:esim/data/model/global/response_model/response_model.dart';
import 'package:esim/data/model/my_esim/my_esim_details_response_model.dart';
import 'package:esim/data/repo/my_esim_details/my_esim_details_repo.dart';
import 'package:esim/view/components/snack_bar/show_custom_snackbar.dart';

class MyEsimDetailsController extends GetxController {
  MyEsimDetailsRepo myEsimDetailsRepo;
  MyEsimDetailsController({required this.myEsimDetailsRepo});
  String esimId = "";
  Esim? esimDetailsDataList = Esim();
  bool isLoading = false;
  bool isTopupAvailable = false;

  // Get plans with pagination - IMPROVED VERSION
  Future<void> getMyEsimController() async {
    // Prevent loading if already loading

    isLoading = true;
    update();

    try {
      ResponseModel responseModel = await myEsimDetailsRepo.getActiveEsimData(esimId);

      if (responseModel.statusCode == 200) {
        MyActiveEsimDetailsResponseModel model = myActiveEsimDetailsResponseModelFromJson(responseModel.responseJson);

        if (model.status?.toLowerCase() == MyStrings.success.toLowerCase()) {
          esimDetailsDataList = model.data?.esim ?? Esim();
          isTopupAvailable = model.data?.esim?.isReloadable ?? false;
          update();
        } else {
          CustomSnackBar.error(errorList: model.message?.error ?? [MyStrings.somethingWentWrong]);
        }
      } else {
        CustomSnackBar.error(errorList: [responseModel.message]);
      }
    } catch (e) {
      printX(e.toString());
      CustomSnackBar.error(errorList: [MyStrings.somethingWentWrong]);
    }

    isLoading = false;
    update();
  }

  bool isSubmitLoading = false;
  int selectedIndex = -1;
  Future<void> downloadQr(String qrData) async {
    try {
      final qrValidationResult = QrValidator.validate(
        data: qrData,
        version: QrVersions.auto,
        errorCorrectionLevel: QrErrorCorrectLevel.L,
      );

      if (qrValidationResult.status == QrValidationStatus.valid) {
        final qrCode = qrValidationResult.qrCode;
        final painter = QrPainter.withQr(
          qr: qrCode!,
          gapless: true,
          eyeStyle: const QrEyeStyle(
            eyeShape: QrEyeShape.square,
            color: Colors.black,
          ),
          dataModuleStyle: const QrDataModuleStyle(
            dataModuleShape: QrDataModuleShape.square,
            color: Colors.black,
          ),
        );

        final bytes = await _renderQrBytesWithWhiteBackground(
          painter: painter,
          size: 300,
        );

        String downloadPath = await _getDownloadDirectory();

        await saveAndOpenFile(
          bytes,
          '$downloadPath/qr_${DateTime.now().millisecondsSinceEpoch}.png',
          'png',
        );
      }
    } catch (e) {
      printX(e);
    }
  }

  //download pdf
  TargetPlatform? platform;
  String downLoadId = "";

  Future<Uint8List> _renderQrBytesWithWhiteBackground({
    required QrPainter painter,
    required double size,
  }) async {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    final rect = Rect.fromLTWH(0, 0, size, size);
    canvas.drawRect(rect, Paint()..color = Colors.white);
    painter.paint(canvas, Size(size, size));
    final image = await recorder.endRecording().toImage(size.toInt(), size.toInt());
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    return byteData!.buffer.asUint8List();
  }

  Future<String> _getDownloadDirectory() async {
    if (Platform.isAndroid) {
      final directory = await getExternalStorageDirectory();
      if (directory != null) {
        return directory.path;
      }
    }
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  Future<void> saveAndOpenFile(List<int> bytes, String path, String extension) async {
    final file = File(path);

    // Save the file to the device
    var d = await file.writeAsBytes(bytes);
    printX(d);
    // Open the file based on its extension
    if (extension == 'pdf') {
      await openPDF(path);
    } else {
      await openFile(path);
    }
  }

  Future<void> openPDF(String path) async {
    final file = File(path);
    if (await file.exists()) {
      final result = await OpenFile.open(path);
      if (result.type != ResultType.done) {
        CustomSnackBar.success(successList: [MyStrings.fileDownloadedSuccess]);
        // CustomSnackBar.error(errorList: ["No App Found For open this pdf file"]);
      }
    } else {
      CustomSnackBar.error(errorList: [MyStrings.fileNotFound]);
    }
  }

  Future<void> openFile(String path) async {
    final file = File(path);
    if (await file.exists()) {
      final result = await OpenFile.open(path);
      printX("${result.type}");
      if (result.type != ResultType.done) {
        // CustomSnackBar.error(errorList: ["No App Found For open this file"]);
        CustomSnackBar.success(successList: [MyStrings.fileDownloadedSuccess]);
      }
    } else {
      CustomSnackBar.error(errorList: [MyStrings.fileNotFound]);
    }
  }
}
