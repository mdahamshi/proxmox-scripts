escape_html() {
    sed -e 's/&/\&amp;/g' -e 's/</\&lt;/g' -e 's/>/\&gt;/g'
}

send_notification() {
    local channel="$1"
    local status="$2"
    local message="$3"

    # Escape HTML special characters
    channel=$(printf "%s" "$channel" | escape_html)
    status=$(printf "%s" "$status" | escape_html)
    message=$(printf "%s" "$message" | escape_html)

    curl -s -X POST "https://api.telegram.org/bot${TG_BOT_TOKEN}/sendMessage" \
        -d chat_id="$TG_CHAT_ID" \
        -d parse_mode="HTML" \
        -d text="<b>Channel:</b> ${channel}
<b>Status:</b> ${status}

${message}" > /dev/null
}