import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:myfatoorah_flutter/embeddedpayment/HtmlPage.dart';
import 'package:myfatoorah_flutter/model/executepayment/MFExecutePaymentRequest.dart';
import 'package:myfatoorah_flutter/model/initsession/SDKInitSessionResponse.dart';
import 'package:myfatoorah_flutter/utils/AppConstants.dart';

import '../myfatoorah_flutter.dart';

class MFPaymentCardView extends StatefulWidget {
  final Color inputColor;
  final Color labelColor;
  final Color errorColor;
  final Color borderColor;
  final int fontSize;
  final int borderWidth;
  final int borderRadius;
  final String cardHolderNameHint;
  final String cardNumberHint;
  final String expiryDateHint;
  final String cvvHint;
  final bool showLabels;
  final String cardHolderNameLabel;
  final String cardNumberLabel;
  final String expiryDateLabel;
  final String cvvLabel;
  int newCardHeight = 220;
  double fieldHeight = 32;
  String environment = "demo.myfatoorah.com";
  HtmlPage? htmlPage;

  MFPaymentCardView({
    Key? key,
    this.inputColor = Colors.black,
    this.labelColor = Colors.black,
    this.errorColor = Colors.red,
    this.borderColor = Colors.grey,
    cardHeight = 220,
    this.fontSize = 14,
    this.borderWidth = 1,
    this.borderRadius = 8,
    this.cardHolderNameHint = "Name On Card",
    this.cardNumberHint = "Number",
    this.expiryDateHint = "MM / YY",
    this.cvvHint = "CVV",
    this.cardHolderNameLabel = "Card Holder Name",
    this.cardNumberLabel = "Card Number",
    this.expiryDateLabel = "ExpiryDate",
    this.cvvLabel = "Security Code",
    this.showLabels = true,
  }) : super(key: key) {
    calculateHeights(cardHeight);
    setEnvironment();

    var html = generateHTML("", "", newCardHeight);

    this.htmlPage = HtmlPage(html);
  }

  void calculateHeights(cardHeight) {
    newCardHeight = cardHeight;

    var labelHeight = 32;

    var totalLabelsHeight = 0;

    if (showLabels)
      totalLabelsHeight = 4 * labelHeight;
    else
      totalLabelsHeight = (1.6 * labelHeight).toInt();

    if (!showLabels) newCardHeight -= totalLabelsHeight;

    fieldHeight = (newCardHeight - totalLabelsHeight) / 3.2;
  }

  void setEnvironment() {
    if (AppConstants.baseUrl == MFBaseURL.TEST)
      environment = "demo.myfatoorah.com";
    else
      environment = "portal.myfatoorah.com";
  }

  @override
  State<StatefulWidget> createState() {
    return htmlPage!;
  }

  String generateHTML(String sessionId, String countryCode, int newCardHeight) {
    return """
      <!DOCTYPE html>
      <html lang="en">
      
      <head>
          <meta charset="UTF-8">
          <meta http-equiv="X-UA-Compatible" content="IE=edge">
          <meta name="viewport" content="width=device-width, initial-scale=1.0">
          <title>Payment Page</title>
          <style></style>
      </head>
      
      <body>
          <script src="https://$environment/cardview/v1/session.js"></script>
          <div id="card-element"></div>
        
      <script type="text/javascript">
          function callExecutePayment(sessionId) {
            Success.postMessage(sessionId);
          }
          function returnPaymentFailed(error) {
            Fail.postMessage(error);
          }
      </script>
          <script>
              var config = {
                  countryCode: "$countryCode",
                  sessionId: "$sessionId",
                  cardViewId: "card-element",
                  style: {
                      cardHeight: $newCardHeight,
                      input: {
                          color: "#${convertToHex(inputColor)}",
                          fontSize: "${fontSize}px",
                          fontFamily: "sans-serif",
                          inputHeight: "${fieldHeight}px",
                          inputMargin: "10px",
                          borderColor: "#${convertToHex(borderColor)}",
                          borderWidth: "${borderWidth}px",
                          borderRadius: "${borderRadius}px",
                          boxShadow: "0px",
                          placeHolder: {
                              holderName: "$cardHolderNameHint",
                              cardNumber: "$cardNumberHint",
                              expiryDate: "$expiryDateHint",
                              securityCode: "$cvvHint",
                          }
                      },
                      label: {
                          display: $showLabels,
                          color: "#${convertToHex(labelColor)}",
                          fontSize: "${fontSize}px",
                          fontFamily: "sans-serif",
                          text: {
                              holderName: "$cardHolderNameLabel",
                              cardNumber: "$cardNumberLabel",
                              expiryDate: "$expiryDateLabel",
                              securityCode: "$cvvLabel",
                          },
                      },
                      error: {
                          borderColor: "#${convertToHex(errorColor)}",
                          borderRadius: "${borderRadius}px",
                          boxShadow: "0px",
                      },
                  },
              };
              this.myFatoorah.init(config);
       
              function submit() {

                  this.myFatoorah.submit() // this.myFatoorah.submit(currency)
                      .then(function(response) {
                          callExecutePayment(response.SessionId);
                      })
                      .catch(function(error) {
                          returnPaymentFailed(error);
                      });        
              };
          </script>
      
      </body>
      
      </html>
        """;
  }

  String convertToHex(Color inputColor) {
    var hex = inputColor.value.toRadixString(16);
    return hex.replaceRange(0, 2, "");
  }

  void load(MFInitiateSessionResponse initSessionResponse) {
//    mMFInitSessionResponse = initSessionResponse;
    htmlPage!.load(
        generateHTML(initSessionResponse.sessionId!,
            initSessionResponse.countryCode!, this.newCardHeight),
        this.newCardHeight);
  }

  void pay(MFExecutePaymentRequest request, String apiLang, Function callback) {
    htmlPage!.submit(request, apiLang, callback);
  }
}
