# 🕵️‍♂️ mySQL_Extractor

A Bash script for ethical hacking, penetration testing, and cybersecurity learning. It automates the process of connecting to vulnerable MySQL services, extracting database contents, and analyzing data with optional features like CSV export, sensitive column detection, and serving results via a local web viewer.

---

## ⚠️ Legal Disclaimer

This tool is intended for educational and authorized use only. Any misuse may be illegal. The author is not responsible for any damage caused by improper usage. Always get explicit permission before scanning or accessing any system.

---

## 📌 Features

- 🔍 Enumerate databases and tables from vulnerable MySQL servers
- 📑 Dump data from accessible tables
- 📤 Export results as CSV files for offline analysis
- 🔐 Highlight columns likely to store sensitive data (user, password, email, etc.)
- 🌐 Serve extracted results via `http.server` for web viewing
- 🕵️ Stealth mode to reduce detection by limiting rows and adding delays

---

## 📦 Setup

1. Clone the repository & run the script:
   ```bash
   git clone https://github.com/SecSentinelGuardian/mysql_extractor.git
   cd mysql_extractor
   chmod +x src/mySQL_Extractor.sh
   ./mySQL_Extractor.sh
   ```
---

## 🧪 Testing Environment

This script has been tested on `Metasploitable 2`, a vulnerable Linux virtual machine designed for penetration testing and ethical hacking exercises. Ensure you are working in a controlled and authorized environment. 

---