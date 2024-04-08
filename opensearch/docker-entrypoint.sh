#!/bin/bash

# Start OpenSearch in the background
bash opensearch-docker-entrypoint.sh



# Wait for OpenSearch to be ready
until curl -XGET --silent --fail localhost:9200; do
  echo "Waiting for OpenSearch..."
  sleep 5
done

echo "OpenSearch is up - installing plugins"

# Install OpenSearch plugins
/usr/share/opensearch/bin/opensearch-plugin install --batch analysis-icu
/usr/share/opensearch/bin/opensearch-plugin install --batch analysis-phonetic

echo "Plugins installed - restarting OpenSearch"

# Start OpenSearch in foreground (this will block the script and keep the container alive)
/usr/share/opensearch/bin/opensearch
