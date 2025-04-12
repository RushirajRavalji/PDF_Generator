import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:signature/signature.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Responsive Bill Maker',
      theme: ThemeData(primarySwatch: Colors.blue),
      debugShowCheckedModeBanner: false,
      home: const BillScreen(),
    );
  }
}

class BillScreen extends StatefulWidget {
  const BillScreen({Key? key}) : super(key: key);
  @override
  State<BillScreen> createState() => _BillScreenState();
}

class _BillScreenState extends State<BillScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController companyNameController = TextEditingController();
  final TextEditingController customerNameController = TextEditingController();
  final TextEditingController itemDescriptionController =
      TextEditingController();
  final TextEditingController itemPriceController = TextEditingController();
  final List<Map<String, dynamic>> items = [];
  bool hasSignature = false;
  Uint8List? signatureImage;
  DateTime selectedDate = DateTime.now();
  final SignatureController _signatureController = SignatureController(
    penStrokeWidth: 2,
    penColor: Colors.black,
    exportBackgroundColor: Colors.white,
  );

  Future<void> pickDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() => selectedDate = picked);
    }
  }

  void addItem() {
    if (itemDescriptionController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter an item description')),
      );
      return;
    }

    if (itemPriceController.text.isEmpty ||
        double.tryParse(itemPriceController.text) == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid price')),
      );
      return;
    }

    final double price = double.parse(itemPriceController.text);

    setState(() {
      items.add({
        'description': itemDescriptionController.text,
        'price': price,
      });

      itemDescriptionController.clear();
      itemPriceController.clear();
    });
  }

  Future<void> handleSignature() async {
    await showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Add Signature'),
            content: SizedBox(
              height: 200,
              child: Signature(
                controller: _signatureController,
                backgroundColor: Colors.grey[200]!,
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  _signatureController.clear();
                  Navigator.of(context).pop();
                },
                child: const Text('Clear'),
              ),
              TextButton(
                onPressed: () async {
                  if (_signatureController.isNotEmpty) {
                    final exportedImage =
                        await _signatureController.toPngBytes();
                    setState(() {
                      signatureImage = exportedImage;
                      hasSignature = true;
                    });
                  }
                  Navigator.of(context).pop();
                },
                child: const Text('Save'),
              ),
            ],
          ),
    );
  }

  double get total =>
      items.fold(0.0, (sum, item) => sum + (item['price'] as double));

  void removeItem(int index) {
    setState(() {
      items.removeAt(index);
    });
  }

  Future<void> createPDF() async {
    if (!_formKey.currentState!.validate()) return;

    final pdf = pw.Document();
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                ' ${companyNameController.text}',
                style: pw.TextStyle(
                  fontSize: 22,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 10),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    'Customer: ${customerNameController.text}',
                    style: pw.TextStyle(fontSize: 18),
                  ),
                  pw.Text(
                    'Date: ${DateFormat('yyyy-MM-dd').format(selectedDate)}',
                    style: pw.TextStyle(fontSize: 18),
                  ),
                ],
              ),
              pw.SizedBox(height: 20),
              pw.Text(
                'Invoice',
                style: pw.TextStyle(
                  fontSize: 24,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 20),
              pw.Table(
                border: pw.TableBorder.all(),
                children: [
                  pw.TableRow(
                    decoration: pw.BoxDecoration(color: PdfColors.grey300),
                    children: [
                      pw.Padding(
                        padding: pw.EdgeInsets.all(8),
                        child: pw.Text(
                          'Item',
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                        ),
                      ),
                      pw.Padding(
                        padding: pw.EdgeInsets.all(8),
                        child: pw.Text(
                          'Price ',
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                  ...items.map(
                    (item) => pw.TableRow(
                      children: [
                        pw.Padding(
                          padding: pw.EdgeInsets.all(8),
                          child: pw.Text(item['description']),
                        ),
                        pw.Padding(
                          padding: pw.EdgeInsets.all(8),
                          child: pw.Text(
                            '${(item['price'] as double).toStringAsFixed(2)}',
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              pw.SizedBox(height: 20),
              pw.Align(
                alignment: pw.Alignment.centerRight,
                child: pw.Text(
                  'Total: ${total.toStringAsFixed(2)}',
                  style: pw.TextStyle(
                    fontSize: 20,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ),
              pw.SizedBox(height: 50),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.end,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.center,
                    children: [
                      hasSignature && signatureImage != null
                          ? pw.Container(
                            width: 150,
                            height: 70,
                            child: pw.Image(pw.MemoryImage(signatureImage!)),
                          )
                          : pw.Container(
                            width: 150,
                            height: 50,
                            decoration: pw.BoxDecoration(
                              border: pw.Border(bottom: pw.BorderSide()),
                            ),
                          ),
                      pw.SizedBox(height: 5),
                      pw.Text('Authorized Signature'),
                    ],
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );

    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/invoice.pdf');
    await file.writeAsBytes(await pdf.save());
    await OpenFile.open(file.path);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Bill')),
      body: SafeArea(
        child: LayoutBuilder(
          builder:
              (context, constraints) => SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      TextFormField(
                        controller: companyNameController,
                        decoration: const InputDecoration(
                          labelText: 'Company Name',
                          border: OutlineInputBorder(),
                        ),
                        validator:
                            (value) =>
                                value == null || value.isEmpty
                                    ? 'Enter company name'
                                    : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: customerNameController,
                        decoration: const InputDecoration(
                          labelText: 'Customer Name',
                          border: OutlineInputBorder(),
                        ),
                        validator:
                            (value) =>
                                value == null || value.isEmpty
                                    ? 'Enter customer name'
                                    : null,
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              'Date: ${DateFormat('yyyy-MM-dd').format(selectedDate)}',
                            ),
                          ),
                          ElevatedButton(
                            onPressed: pickDate,
                            child: const Text('Choose Date'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              'Signature: ${hasSignature ? 'Added' : 'Not Added'}',
                            ),
                          ),
                          ElevatedButton(
                            onPressed: handleSignature,
                            child: const Text('Add Signature'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 30),
                      const Text('Add Items:', style: TextStyle(fontSize: 18)),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            flex: 2,
                            child: TextField(
                              controller: itemDescriptionController,
                              decoration: const InputDecoration(
                                labelText: 'Description',
                                border: OutlineInputBorder(),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            flex: 1,
                            child: TextField(
                              controller: itemPriceController,
                              decoration: const InputDecoration(
                                labelText: 'Price ',
                                border: OutlineInputBorder(),
                              ),
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                    decimal: true,
                                  ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          ElevatedButton(
                            onPressed: addItem,
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.all(16),
                              minimumSize: const Size(48, 48),
                            ),
                            child: const Icon(Icons.add),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      if (items.isEmpty)
                        const Center(child: Text('No items added yet'))
                      else
                        Card(
                          elevation: 2,
                          child: ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: items.length,
                            separatorBuilder:
                                (context, index) => const Divider(height: 1),
                            itemBuilder:
                                (context, index) => ListTile(
                                  title: Text(items[index]['description']),
                                  subtitle: Text(
                                    '₹${(items[index]['price'] as double).toStringAsFixed(2)}',
                                  ),
                                  trailing: IconButton(
                                    icon: const Icon(Icons.delete),
                                    color: Colors.red,
                                    onPressed: () => removeItem(index),
                                  ),
                                ),
                          ),
                        ),
                      const SizedBox(height: 30),
                      ElevatedButton.icon(
                        onPressed: createPDF,
                        icon: const Icon(Icons.picture_as_pdf),
                        label: const Text('Create PDF Bill'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    companyNameController.dispose();
    customerNameController.dispose();
    itemDescriptionController.dispose();
    itemPriceController.dispose();
    _signatureController.dispose();
    super.dispose();
  }
}
