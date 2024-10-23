#!/bin/sh
set -e
echo "alertmanager_choice watchdog starting"

case $choice in
	internal)
		;;
	all)
		;;
	external)
		;;
	*)
		echo "Invalid choice: '$choice' - must be one of 'internal', 'all', 'external'"
		exit 1
		;;
esac

Authorization="Authorization: Basic $(echo "${username:-admin}:${password:-prom-operator}" | tr -d '\n' | base64 | tr -d '\n')"
while true; do
	echo checking alertmanager choice
	req_url="${url:-http://localhost:3000/api/v1/ngalert}"

	echo ""
	re="$(curl -H "$Authorization" "$req_url")"

	current_choice="$(echo "$re" | jq -r '.alertmanagersChoice')"
	current_count="$(echo "$re" | jq -r '.numExternalAlertmanagers')"

	if [ $current_count -eq 0 ]; then
		echo "no external alertmanagers configured"
		if [ "$current_choice" = "external" ]; then
			curl -sSf -X POST -H "$Authorization"-H "Content-Type: application/json" -d '{\"alertmanagersChoice\":\"internal\"}' "$req_url/admin_config"
		fi
	else
		if [ "$current_choice" != "$choice" ]; then
			curl -sSf -X POST -H "$Authorization" -H "Content-Type: application/json" -d "{\"alertmanagersChoice\":\"$choice\"}" "$req_url/admin_config"
		fi
	fi

	if [ $? -eq 0 ]; then
		echo ""
		echo "Alertmanager choice validated. Next validation in 5 minutes."
		sleep 300
	else
		echo "Failed to update alertmanager choice. Retrying in 10 seconds."
		sleep 10
	fi
done
