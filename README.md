# PDF Generator - Responsive Bill Maker

A Flutter application that allows users to create professional-looking PDF invoices/bills by entering company and customer details, adding multiple items with prices, including digital signatures, and exporting the final bill as a PDF file.

## Table of Contents

- [Features](#features)
- [Screenshots](#screenshots)
- [Getting Started](#getting-started)
  - [Prerequisites](#prerequisites)
  - [Installation](#installation)
- [Usage](#usage)
- [Project Structure](#project-structure)
- [Dependencies](#dependencies)
- [Key Functionalities](#key-functionalities)
- [Contributing](#contributing)
- [License](#license)

## Features

- Enter company and customer details for the invoice header
- Select and customize invoice date
- Add, view, and remove multiple line items with descriptions and prices
- Automatic calculation of the total amount
- Add digital signature directly within the app
- Generate and save a professionally styled PDF invoice
- Open the generated PDF directly from the app
- Responsive design that works on various device sizes

## Screenshots

> Loading ...

## Getting Started

Follow these instructions to get a copy of the project up and running on your local machine.

### Prerequisites

- [Flutter SDK](https://flutter.dev/docs/get-started/install) (version 3.7.0 or higher)
- Dart (included with Flutter)
- An Android or iOS device/emulator

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/yourusername/pdfgenerator.git
   cd pdfgenerator
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Run the app**
   ```bash
   flutter run
   ```

## Usage

1. Launch the app on your device or emulator.
2. Enter the **Company Name** in the text field.
3. Enter the **Customer Name** in the text field.
4. Tap **Choose Date** to select the invoice date.
5. Tap **Add Signature** to add your digital signature.
6. Under **Add Items**, enter the item description and price, then tap the **+** button to add it to the list.
7. Repeat step 6 for all items you wish to include.
8. Review the list of items; tap the delete icon to remove any if needed.
9. Tap **Create PDF Bill** to generate and view the invoice PDF.
10. The PDF will automatically open for review and can be shared or saved.

## Project Structure

```
pdfgenerator/
├── lib/
│   └── main.dart       # Main application file containing all logic
├── android/            # Android platform-specific files
├── ios/                # iOS platform-specific files
├── linux/              # Linux platform-specific files
├── macos/              # macOS platform-specific files
├── windows/            # Windows platform-specific files
├── web/                # Web platform-specific files
└── pubspec.yaml        # Flutter project configuration and dependencies
```

## Dependencies

| Package           | Description                                        | Version      |
|-------------------|----------------------------------------------------|--------------|
| `pdf`             | Generate PDF documents                             | ^3.11.3      |
| `path_provider`   | Find commonly used locations on device filesystem  | ^2.1.5       |
| `open_file`       | Open files with default applications               | ^3.5.10      |
| `intl`            | Internationalization and date formatting           | ^0.20.2      |
| `signature`       | Capture digital signatures                         | ^6.0.0       |
| `typed_data`      | Typed data representations                         | ^1.4.0       |
| `flutter/material`| Core Flutter UI components                         | sdk: flutter |

## Key Functionalities

### Form Validation
The app implements form validation to ensure required fields are filled before generating a PDF.

### Signature Capture
Users can add their signature directly within the app using the signature canvas, which is then embedded in the generated PDF.

### PDF Generation
The PDF is created using the `pdf` package with the following components:
- Company header with name
- Customer details and date
- Item list with descriptions and prices
- Total amount calculation
- Digital signature field

### File Operations
Generated PDFs are temporarily stored on the device and automatically opened with the default PDF viewer application.

### State Management
The app uses Flutter's built-in StatefulWidget pattern for managing state, including form inputs, item list, and signature data.

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is licensed under the MIT License - see the LICENSE file for details.

