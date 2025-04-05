import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pdfWidgets;
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import 'dart:io';
import 'package:intl/intl.dart';

void main() {
  runApp(MyApp());
}

// Main app widget
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Simple Bill Maker',
      theme: ThemeData(primarySwatch: Colors.blue),
      debugShowCheckedModeBanner: false,
      home: BillScreen(),
    );
  }
}

//? Screen for entering bill information
class BillScreen extends StatefulWidget {
  const BillScreen({super.key});

  @override
  State<BillScreen> createState() => _BillScreenState();
}

class _BillScreenState extends State<BillScreen> {
  
  final _formKey = GlobalKey<FormState>();

  // Controllers for text fields
  TextEditingController customerNameController = TextEditingController();
  TextEditingController itemDescriptionController = TextEditingController();
  TextEditingController itemPriceController = TextEditingController();


  List<Map<String, dynamic>> itemsList = [];

  // Selected date (default to current date)
  DateTime selectedDate = DateTime.now();

  // Function to pick date
  Future<void> pickDate() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null) {
      setState(() {
        selectedDate = pickedDate;
      });
    }
  }

  // Function to add item to list
  void addItem() {
    if (itemDescriptionController.text.isNotEmpty &&
        itemPriceController.text.isNotEmpty) {
      setState(() {
        itemsList.add({
          'description': itemDescriptionController.text,
          'price': double.parse(itemPriceController.text),
        });
        // Clear input fields
        itemDescriptionController.clear();
        itemPriceController.clear();
      });
    }
  }

  // Function to remove item from list
  void removeItem(int index) {
    setState(() {
      itemsList.removeAt(index);
    });
  }

  // Function to create PDF
  Future<void> createPDF() async {
    if (!_formKey.currentState!.validate()) return;

    // Create PDF document
    final pdf = pdfWidgets.Document();

    // Add a page to the PDF
    pdf.addPage(
      pdfWidgets.Page(
        pageFormat: PdfPageFormat.a4,
        build: (context) {
          return pdfWidgets.Column(
            crossAxisAlignment: pdfWidgets.CrossAxisAlignment.start,
            children: [
              // Header section
              pdfWidgets.Row(
                mainAxisAlignment: pdfWidgets.MainAxisAlignment.spaceBetween,
                children: [
                  pdfWidgets.Text(
                    'Customer: ${customerNameController.text}',
                    style: pdfWidgets.TextStyle(fontSize: 18),
                  ),
                  pdfWidgets.Text(
                    'Date: ${DateFormat('yyyy-MM-dd').format(selectedDate)}',
                    style: pdfWidgets.TextStyle(fontSize: 18),
                  ),
                ],
              ),

              pdfWidgets.SizedBox(height: 20),

              // Title
              pdfWidgets.Text(
                'Invoice',
                style: pdfWidgets.TextStyle(
                  fontSize: 24,
                  fontWeight: pdfWidgets.FontWeight.bold,
                ),
              ),

              pdfWidgets.SizedBox(height: 20),

              // Items table
              pdfWidgets.Table(
                border: pdfWidgets.TableBorder.all(),
                children: [
                  // Table header
                  pdfWidgets.TableRow(
                    decoration: pdfWidgets.BoxDecoration(
                      color: PdfColors.grey300,
                    ),
                    children: [
                      pdfWidgets.Padding(
                        padding: pdfWidgets.EdgeInsets.all(8),
                        child: pdfWidgets.Text(
                          'Item',
                          style: pdfWidgets.TextStyle(
                            fontWeight: pdfWidgets.FontWeight.bold,
                          ),
                        ),
                      ),
                      pdfWidgets.Padding(
                        padding: pdfWidgets.EdgeInsets.all(8),
                        child: pdfWidgets.Text(
                          'Price',
                          style: pdfWidgets.TextStyle(
                            fontWeight: pdfWidgets.FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),

                  // Table rows with items
                  ...itemsList.map((item) {
                    return pdfWidgets.TableRow(
                      children: [
                        pdfWidgets.Padding(
                          padding: pdfWidgets.EdgeInsets.all(8),
                          child: pdfWidgets.Text(item['description']),
                        ),
                        pdfWidgets.Padding(
                          padding: pdfWidgets.EdgeInsets.all(8),
                          child: pdfWidgets.Text(
                            '${item['price'].toStringAsFixed(2)}',
                          ),
                        ),
                      ],
                    );
                  }),
                ],
              ),

              pdfWidgets.SizedBox(height: 20),

              // Total calculation
              pdfWidgets.Align(
                alignment: pdfWidgets.Alignment.centerRight,
                child: pdfWidgets.Text(
                  'Total: ${calculateTotal().toStringAsFixed(2)}',
                  style: pdfWidgets.TextStyle(
                    fontSize: 20,
                    fontWeight: pdfWidgets.FontWeight.bold,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );

    // Save PDF file
    final output = await getTemporaryDirectory();
    final file = File('${output.path}/invoice.pdf');
    await file.writeAsBytes(await pdf.save());

    // Open the PDF file
    OpenFile.open(file.path);
  }

  // Calculate total amount
  double calculateTotal() {
    double total = 0;
    for (var item in itemsList) {
      total += item['price'];
    }
    return total;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Create Bill')),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Customer name input
              TextFormField(
                controller: customerNameController,
                decoration: InputDecoration(
                  labelText: 'Customer Name',
                  border: OutlineInputBorder(),
                ),
                validator:
                    (value) => value!.isEmpty ? 'Please enter a name' : null,
              ),

              SizedBox(height: 20),

              // Date picker
              Row(
                children: [
                  Text(
                    'Date: ${DateFormat('yyyy-MM-dd').format(selectedDate)}',
                  ),
                  SizedBox(width: 20),
                  ElevatedButton(
                    onPressed: pickDate,
                    child: Text('Choose Date'),
                  ),
                ],
              ),

              SizedBox(height: 30),

              // Add items section
              Text('Add Items:', style: TextStyle(fontSize: 18)),
              SizedBox(height: 10),

              Row(
                children: [
                  // Item description input
                  Expanded(
                    child: TextFormField(
                      controller: itemDescriptionController,
                      decoration: InputDecoration(
                        labelText: 'Item Description',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),

                  SizedBox(width: 10),

                  // Item price input
                  Expanded(
                    child: TextFormField(
                      controller: itemPriceController,
                      decoration: InputDecoration(
                        labelText: 'Price',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ),

                  SizedBox(width: 10),

                  // Add button
                  IconButton(
                    onPressed: addItem,
                    icon: Icon(Icons.add_box, size: 35),
                    color: Colors.blue,
                  ),
                ],
              ),

              SizedBox(height: 20),

              // List of items
              Expanded(
                child:
                    itemsList.isEmpty
                        ? Center(child: Text('No items added yet'))
                        : ListView.builder(
                          itemCount: itemsList.length,
                          itemBuilder: (context, index) {
                            return ListTile(
                              title: Text(itemsList[index]['description']),
                              subtitle: Text(
                                '${itemsList[index]['price'].toStringAsFixed(2)}',
                              ),
                              trailing: IconButton(
                                icon: Icon(Icons.delete, color: Colors.red),
                                onPressed: () => removeItem(index),
                              ),
                            );
                          },
                        ),
              ),

              // Generate PDF button
              ElevatedButton.icon(
                onPressed: createPDF,
                icon: Icon(Icons.picture_as_pdf),
                label: Text('Create PDF Bill'),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 15, horizontal: 30),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
