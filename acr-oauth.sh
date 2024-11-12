AZURE_FEDERATED_TOKEN=$(cat $AZURE_FEDERATED_TOKEN_FILE)
AZURE_CONTAINER_REGISTRY="$ORAS_REGISTRY_HOST"

POST_HEADER="Content-Type: application/x-www-form-urlencoded"

# Request an Access Token for AzureRM

RAW_ACCESS_TOKEN=$(curl -s -X POST \
	-H "$POST_HEADER" \
	-d 'scope=https://management.core.windows.net/.default&grant_type=client_credentials&client_assertion='$AZURE_FEDERATED_TOKEN'&client_id='$AZURE_CLIENT_ID'&client_assertion_type=urn:ietf:params:oauth:client-assertion-type:jwt-bearer' \
	https://login.microsoftonline.com/$AZURE_TENANT_ID/oauth2/v2.0/token)

ACCESS_TOKEN=$(echo $RAW_ACCESS_TOKEN | cut -d ":" -f 5 | sed 's/"//g' | sed 's/}$//' | xargs)

# Request an Access Token for Azure Container Registry

RAW_REFRESH_TOKEN=$(curl -s -X POST -H "$POST_HEADER" \
        -d "grant_type=access_token&service=$AZURE_CONTAINER_REGISTRY&access_token=$ACCESS_TOKEN" \
	"https://$AZURE_CONTAINER_REGISTRY/oauth2/exchange")

REFRESH_TOKEN=$(echo $RAW_REFRESH_TOKEN | cut -d ":" -f 2 | sed 's/"//g' | sed 's/}$//' | xargs)

# Output the refresh token so it can be used as the docker login password
echo "$REFRESH_TOKEN"
