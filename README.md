# Simple Bill Maker

A Flutter application that allows users to create simple PDF invoices (bills) by entering customer details, adding multiple items with prices, and exporting the final bill as a PDF file.

## Table of Contents

- [Features](#features)
- [Screenshots](#screenshots)
- [Getting Started](#getting-started)
  - [Prerequisites](#prerequisites)
  - [Installation](#installation)
- [Usage](#usage)
- [Project Structure](#project-structure)
- [Dependencies](#dependencies)
- [Contributing](#contributing)
- [License](#license)

## Features

- Enter customer name and select invoice date.
- Add, view, and remove multiple line items (description and price).
- Automatic calculation of the total amount.
- Generate and save a styled PDF invoice.
- Open the generated PDF directly from the app.

## Screenshots

> Loading ...

## Getting Started

Follow these instructions to get a copy of the project up and running on your local machine.

### Prerequisites

- [Flutter SDK](https://flutter.dev/docs/get-started/install) (version 2.0 or higher)
- Dart (included with Flutter)
- An Android or iOS device/emulator

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/RushirajRavalji/PDF_Generator.git
   cd simple-bill-maker
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
2. Enter the **Customer Name** in the text field.
3. Tap **Choose Date** to select the invoice date.
4. Under **Add Items**, enter the item description and price, then tap the **+** button to add it to the list.
5. Repeat step 4 for all items you wish to include.
6. Review the list of items; swipe or tap the delete icon to remove any.
7. Tap **Create PDF Bill** to generate and view the invoice PDF.

## Project Structure

```
lib/
├── main.dart       # Entry point and UI logic
├── pdf_generator.dart  # (Optional) Extracted PDF creation logic
└── widgets/        # (Optional) Custom UI components
```

## Dependencies

| Package           | Description                              | Version      |
|-------------------|------------------------------------------|--------------|
| `pdf`             | Generate PDF documents                   | ^3.6.0       |
| `path_provider`   | Find commonly used locations on device   | ^2.0.11      |
| `open_file`       | Open files with default apps             | ^3.2.1       |
| `intl`            | Internationalization and date formatting | ^0.17.0      |
| `flutter/material`| Core Flutter widgets                     | sdk: flutter |

> **Note:** Check [pub.dev](https://pub.dev) for the latest versions.

## Contributing

Contributions are welcome! Please open an issue or submit a pull request with your improvements.

