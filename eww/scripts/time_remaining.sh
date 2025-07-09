n=$(date +%s);t=$(date -d "$(printf '%(%Y-%m-%d)T' -1) 21:30:00" +%s);((t<=n))&&((t+=86400));echo $((t-n))
