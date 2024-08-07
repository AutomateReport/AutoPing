#!/bin/bash 

  

# Daftar situs yang akan diperiksa 

SITES=(" https://backoffice.asabri.co.id/" " https://eproc.asabri.co.id/" " https://mitra.asabri.co.id/" " https://pensiun.asabri.co.id/login" ) 

  

# Dapatkan tahun dan hari saat ini 

YEAR=$(date +"%Y") 

DAY=$(date +"%Y-%m-%d") 

  

# File CSV untuk menyimpan hasil, dengan nama berdasarkan tahun 

OUTPUT_FILE="/path/to/monitoring_results_$YEAR.csv" 

  

# File CSV untuk menyimpan hasil harian 

DAILY_FILE="/path/to/monitoring_results_$DAY.csv" 

  

# Tulis header CSV harian jika file tidak ada 

if [ ! -f "$DAILY_FILE" ]; then 

  echo "Timestamp,Situs,Status,ResponseTime,HTTPCode,SSLValidity" > "$DAILY_FILE" 

fi 

  

# Tulis header CSV tahunan jika file tidak ada 

if [ ! -f "$OUTPUT_FILE" ]; then 

  echo "Timestamp,Situs,Status,ResponseTime,HTTPCode,SSLValidity" > "$OUTPUT_FILE" 

fi 

  

# Dapatkan timestamp saat ini 

TIMESTAMP=$(date +"%Y-%m-%d %H:%M:%S") 

  

# Fungsi untuk memeriksa SSL Certificate Validity 

check_ssl() { 

  local domain=$1 

  local ssl_expiry_date=$(echo | openssl s_client -connect $domain:443 -servername $domain 2>/dev/null | openssl x509 -noout -dates | grep 'notAfter=' | sed 's/notAfter=//') 

  local expiry_epoch=$(date -d "$ssl_expiry_date" +%s) 

  local now_epoch=$(date +%s) 

  local days_left=$(( (expiry_epoch - now_epoch) / 86400 )) 

  echo "$days_left days remaining" 

} 

  

# Loop melalui daftar situs dan periksa status 

for SITE in "${SITES[@]}"; do 

  # Hapus skema HTTP/HTTPS untuk SSL/TLS check 

  DOMAIN=$(echo $SITE | sed 's|http[s]://||' | awk -F/ '{print $1}') 

  

  # Cek status HTTP dan waktu respons 

  HTTP_STATUS=$(curl -o /dev/null -s -w "%{http_code}" "$SITE") 

  RESPONSE_TIME=$(curl -o /dev/null -s -w "%{time_total}" "$SITE") 

   

  # Cek ketersediaan situs menggunakan ping 

  PING_STATUS=$(ping -c 1 -W 1 "$DOMAIN" > /dev/null 2>&1 && echo "Reachable" || echo "Unreachable") 

   

  # Cek validitas SSL 

  SSL_VALIDITY=$(check_ssl $DOMAIN) 

   

  # Tulis hasil ke file CSV harian 

  echo "$TIMESTAMP,$SITE,$PING_STATUS,$RESPONSE_TIME,$HTTP_STATUS,$SSL_VALIDITY" >> "$DAILY_FILE" 

   

  # Tulis hasil ke file CSV tahunan 

  echo "$TIMESTAMP,$SITE,$PING_STATUS,$RESPONSE_TIME,$HTTP_STATUS,$SSL_VALIDITY" >> "$OUTPUT_FILE" 

done 