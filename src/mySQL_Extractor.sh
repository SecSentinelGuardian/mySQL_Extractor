#!/bin/bash

# ==============================================
# MySQL Extractor Script
# Author: SSG (Sec Sentinel Guardian)
# Purpose: Ethical data enumeration from exposed MySQL services
# Version: 1.0
# ==============================================

# === Function to get credentials from the user ===
get_credentials() {
    echo "[*] Enter MySQL connection details:"
    read -p "MySQL Host IP: " HOST
    read -p "MySQL Username [default: root]: " USER
    USER=${USER:-root}
    read -s -p "MySQL Password (leave blank if none): " PASSWORD
    echo
}

# === Function to select optional features ===
select_features() {
    echo
    echo "[*] Optional features:"
    echo "1. Export as CSV"
    echo "2. Highlight likely credential columns"
    echo "3. Serve via local web viewer"
    echo "4. All of the above"
    echo "5. None"
    read -p "Select (1-5): " FEATURE_MODE

    # Validate user input
    if [[ ! "$FEATURE_MODE" =~ ^[1-5]$ ]]; then
        echo "[!] Invalid feature mode selected. Please choose between 1 and 5."
        exit 1
    fi
}

# === Function to dump databases ===
dump_database() {
    echo "[*] Connecting to $HOST..."
    DATABASES=$(mysql $PASS_FLAG -e "SHOW DATABASES;" 2>/dev/null | grep -v Database)

    if [ -z "$DATABASES" ]; then
        echo "[!] Failed to retrieve databases. Check credentials or target availability."
        exit 1
    fi

    echo "[*] Connected. Found databases:"
    echo "$DATABASES"

    for DB in $DATABASES; do
        if [[ "$DB" =~ ^(information_schema|performance_schema)$ ]]; then
            echo "[-] Skipping $DB (internal schema)"
            continue
        fi

        echo "[+] Dumping database: $DB"
        TABLES=$(mysql $PASS_FLAG -D "$DB" -e "SHOW TABLES;" 2>/dev/null | grep -v Tables)

        for TABLE in $TABLES; do
            echo "  [>>] $DB.$TABLE"
            echo "===== $DB.$TABLE =====" >> "$OUTFILE"
            mysql $PASS_FLAG -D "$DB" -e "SELECT * FROM $TABLE;" 2>/dev/null >> "$OUTFILE"
            echo "" >> "$OUTFILE"

            # Export as CSV
            if [[ "$FEATURE_MODE" =~ ^(1|4)$ ]]; then
                mysql $PASS_FLAG -D "$DB" -B -e "SELECT * FROM $TABLE;" 2>/dev/null | sed 's/\t/,/g' > "$CSV_FOLDER/${DB}_${TABLE}.csv"
            fi

            # Highlight sensitive columns
            if [[ "$FEATURE_MODE" =~ ^(2|4)$ ]]; then
                echo "    [*] Checking for sensitive fields..."
                COLUMNS=$(mysql $PASS_FLAG -D "$DB" -e "SHOW COLUMNS FROM $TABLE;" 2>/dev/null | awk '{print $1}')
                for COL in $COLUMNS; do
                    if [[ "$COL" =~ ^(user|username|email|pass|password)$ ]]; then
                        echo "    [!] Likely sensitive column in $DB.$TABLE: $COL"
                    fi
                done
            fi

            # Serve HTML
            if [[ "$FEATURE_MODE" =~ ^(3|4)$ ]]; then
                echo "<h2>$DB.$TABLE</h2><pre>" >> "$HTML_FILE"
                mysql $PASS_FLAG -D "$DB" -e "SELECT * FROM $TABLE;" 2>/dev/null >> "$HTML_FILE"
                echo "</pre><hr>" >> "$HTML_FILE"
            fi
        done
    done
}

# === Main Script Execution ===
get_credentials
select_features

# Setup connection flags
PASS_FLAG="-h $HOST --skip-ssl -u $USER"
if [ -n "$PASSWORD" ]; then
    PASS_FLAG="$PASS_FLAG -p$PASSWORD"
fi

# Setup output directories
TIMESTAMP=$(date +%Y%m%d-%H%M%S)
CSV_FOLDER="csv-dump-$TIMESTAMP"
RESULTS_DIR="results"
OUTFILE="$RESULTS_DIR/mysql-dump-$TIMESTAMP.txt"
HTML_FILE="$RESULTS_DIR/mysql-dump-$TIMESTAMP.html"

mkdir -p "$CSV_FOLDER"
mkdir -p "$RESULTS_DIR"

dump_database

# Clean up CSV folder if not selected
if [[ ! "$FEATURE_MODE" =~ ^(1|4)$ ]]; then
    rm -rf "$CSV_FOLDER"
fi

echo "[✓] Dump complete. Saved to $OUTFILE and $HTML_FILE"

# Serve web viewer
if [[ "$FEATURE_MODE" =~ ^(3|4)$ ]]; then
    echo "[🌐] Serving at: http://localhost:8080"
    (cd "$RESULTS_DIR" && python3 -m http.server 8080 > /dev/null 2>&1 &)
fi