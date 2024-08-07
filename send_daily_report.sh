#!/bin/bash

# Dapatkan tanggal hari ini dan kemarin
TODAY=$(date +"%Y-%m-%d")
YESTERDAY=$(date -d "yesterday" +"%Y-%m-%d")

# File CSV untuk hasil harian kemarin
DAILY_FILE="/path/to/monitoring_results_$YESTERDAY.csv"

# File sementara untuk laporan email
EMAIL_REPORT="/tmp/daily_report.txt"

# Cek apakah file CSV harian kemarin ada
if [ -f "$DAILY_FILE" ]; then
  # Hitung total uptime dan validitas SSL
  UPTIME_COUNT=$(grep "Reachable" "$DAILY_FILE" | wc -l)
  SSL_VALIDITY=$(awk -F, '{print $6}' "$DAILY_FILE" | sort | uniq -c | awk '{print "Valid SSL days remaining: " $2 " - Count: " $1}' | sort -k3nr)

  # Tulis laporan ke file sementara
  echo "Daily Monitoring Report for $YESTERDAY" > "$EMAIL_REPORT"
  echo "Total Uptime Sites: $UPTIME_COUNT" >> "$EMAIL_REPORT"
  echo "" >> "$EMAIL_REPORT"
  echo "$SSL_VALIDITY" >> "$EMAIL_REPORT"

  # Kirim email menggunakan msmtp
  cat "$EMAIL_REPORT" | msmtp -s "Daily Monitoring Report for $YESTERDAY" jesinamora08@gmail.com

  # Hapus file laporan sementara
  rm "$EMAIL_REPORT"
fi
