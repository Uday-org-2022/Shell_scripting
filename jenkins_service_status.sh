# Check Jenkins service status
echo "Checking Jenkins service status..."
counter=0
max_attempts=5
while [ $counter -lt $max_attempts ]; do
    status=$(sudo systemctl is-active jenkins)
    if [ "$status" == "active" ]; then
        echo "Jenkins service is running."
        break
    else
        echo "Jenkins service is not running. Retrying in 5 seconds..."
        sleep 5
        counter=$((counter + 1))
    fi
done

# Exit if Jenkins service is not running after all attempts
if [ "$status" != "active" ]; then
    echo "Failed to start Jenkins service after $max_attempts attempts. Exiting..."
    exit 1
fi