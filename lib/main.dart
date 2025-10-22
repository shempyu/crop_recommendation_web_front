import 'dart:developer';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Crop Recommendation App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
        fontFamily: 'Roboto',
      ),
      home: const CropPredictPage(),
    );
  }
}

class CropPredictPage extends StatefulWidget {
  const CropPredictPage({super.key});

  @override
  State<CropPredictPage> createState() => _CropPredictPageState();
}

class _CropPredictPageState extends State<CropPredictPage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController nCtrl = TextEditingController();
  final TextEditingController pCtrl = TextEditingController();
  final TextEditingController kCtrl = TextEditingController();
  final TextEditingController tempCtrl = TextEditingController();
  final TextEditingController humidityCtrl = TextEditingController();
  final TextEditingController phCtrl = TextEditingController();
  final TextEditingController rainCtrl = TextEditingController();

  String? _result;
  bool _isLoading = false;

  final String apiUrl = "https://python-api-tusm.onrender.com/predict";

  Future<void> _callCropApi() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _result = null;
    });

    final requestBody = {
      "N": double.parse(nCtrl.text),
      "P": double.parse(pCtrl.text),
      "K": double.parse(kCtrl.text),
      "temperature": double.parse(tempCtrl.text),
      "humidity": double.parse(humidityCtrl.text),
      "ph": double.parse(phCtrl.text),
      "rainfall": double.parse(rainCtrl.text),
    };

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _result = data["recommended_crop"] ?? "No crop found";
        });
      } else {
        setState(() {
          _result = "Error: ${response.statusCode}";
        });
      }
    } catch (e) {
      setState(() {
        _result = "Failed to connect to server.";
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Widget _inputCard(String label, TextEditingController controller) {
    return Card(
      elevation: 6,
      color: Colors.white,
      shadowColor: Colors.green.withOpacity(0.3),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        child: TextFormField(
          controller: controller,
          keyboardType: TextInputType.number,
          style: const TextStyle(color: Colors.black87, fontSize: 16),
          validator: (val) =>
              val == null || val.isEmpty ? "Enter $label" : null,
          decoration: InputDecoration(
            labelText: label,
            labelStyle: const TextStyle(color: Colors.green, fontSize: 16),
            border: InputBorder.none,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          title: const Text(
            "🌱 Crop Recommendation",
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green),
          ),
          centerTitle: true,
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFDFF7DF), Color(0xFFBDECB6), Color(0xFFA4D9A2)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: SafeArea(
            child: Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    12,
                    0,
                    12,
                    70,
                  ), // reduced side & bottom padding
                  child: Form(
                    key: _formKey,
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          const Text(
                            "Enter Soil & Weather Details",
                            style: TextStyle(
                              fontSize: 18, // reduced size slightly
                              fontWeight: FontWeight.w700,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 10),
                          _inputCard("Nitrogen (N) – kg/ha", nCtrl),
                          _inputCard("Phosphorus (P) – kg/ha", pCtrl),
                          _inputCard("Potassium (K) – kg/ha", kCtrl),
                          _inputCard("Temperature (°C)", tempCtrl),
                          _inputCard("Humidity (%)", humidityCtrl),
                          _inputCard("pH Value", phCtrl),
                          _inputCard("Rainfall (mm)", rainCtrl),
                          const SizedBox(height: 10),

                          // 🔹 Recommended Crop Card
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 400),
                            width: double.infinity,
                            margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 3),
                            padding: const EdgeInsets.symmetric(
                              vertical: 14,
                              horizontal: 14,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(14),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.green.withOpacity(0.25),
                                  blurRadius: 8,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  "Recommended Crop:",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green,
                                  ),
                                ),
                                Expanded(
                                  child: Align(
                                    alignment: Alignment.centerRight,
                                    child: _isLoading
                                        ? const SizedBox(
                                            height: 22,
                                            width: 22,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2.6,
                                              color: Colors.green,
                                            ),
                                          )
                                        : Text(
                                            _result ?? "—",
                                            textAlign: TextAlign.right,
                                            style: const TextStyle(
                                              fontSize: 17,
                                              fontWeight: FontWeight.w700,
                                              color: Colors.black87,
                                            ),
                                          ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),
                ),

                // 🔹 Fixed "Get Crop Recommendation" button at bottom center
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 22),
                    child: SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green.shade700,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          elevation: 5,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        onPressed: _isLoading
                            ? null
                            : () {
                                FocusScope.of(context).unfocus();
                                _callCropApi();
                              },
                        icon: const Icon(
                          Icons.agriculture,
                          color: Colors.white,
                        ),
                        label: const Text(
                          "Get Crop Recommendation",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
