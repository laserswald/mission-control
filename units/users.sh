
ensure_user() {
	username=$1; shift

	if ! id "$username" >/dev/null 2>&1
	then
		echo "Adding user account"
		useradd \
		  --user-group \
		  --create-home \
		  "$username"
	fi

	echo "User account $username exists."
}

