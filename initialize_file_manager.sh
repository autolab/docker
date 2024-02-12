# Prompt user for username
read -p "Enter username: " username

# Check if the .htpasswd file already exists
htpasswd_file="./nginx/.htpasswd"
if [ -f "$htpasswd_file" ]; then
    echo "Adding user '$username' to existing .htpasswd file."
    htpasswd "$htpasswd_file" "$username"
else
    echo "Creating new .htpasswd file with user '$username'."
    htpasswd -c "$htpasswd_file" "$username"
fi

echo "Basic authentication credentials created for $username."