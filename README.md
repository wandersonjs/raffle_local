# 🎟️ Raffle App – Flutter + SQLite

A simple and fully offline mobile application for managing a single raffle at a time. Developed as a personal project to explore Flutter and local data persistence using SQLite.

## 📱 Features

- **Single Raffle Management**
  - Register one raffle at a time
  - Define prize name, prize value, ticket (quota) value, and total number of tickets

- **Ticket Sales**
  - Select one or multiple ticket numbers for sale
  - Option to select all available numbers at once
  - Assign buyer information to sold tickets

- **Automated Drawing**
  - Drawing is only allowed if at least one ticket has been sold
  - Random selection among sold numbers
  - Displays the winning number and buyer details

- **Offline Functionality**
  - All data is stored locally using SQLite
  - No internet connection required

- **User Interface**
  - Clean and responsive UI built with Flutter
  - Simple navigation and intuitive interactions

## 🛠️ Technologies Used

- [Flutter](https://flutter.dev/)
- [Dart](https://dart.dev/)
- [SQLite](https://pub.dev/packages/sqflite)

## 🚀 Getting Started

1. Clone the repository:
   ```bash
   git clone https://github.com/your-username/raffle-app.git
