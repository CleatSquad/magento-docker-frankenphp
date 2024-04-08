# Magento Docker Environment Setup ([FrankenPHP](https://frankenphp.dev/))

This README provides instructions for setting up a Magento 2 environment using Docker. The setup includes containers for FrankenPHP, MariaDB, OpenSearch, and Redis.

## Prerequisites

- Docker <!-- Docker is a platform that uses OS-level virtualization to deliver software in packages called containers. -->
- Docker Compose <!-- Docker Compose is a tool for defining and running multi-container Docker applications. -->
- Git (optional, for cloning the repository) <!-- Git is a distributed version control system for tracking changes in source code during software development. -->

## Containers Included

- [FrankenPHP](https://frankenphp.dev/): Web server to serve Magento pages based on FrankenPHP. <!-- FrankenPHP is a web server that serves Magento pages. -->
- MariaDB: Database server for Magento data. <!-- MariaDB is a community-developed, commercially supported fork of the MySQL relational database management system. -->
- OpenSearch: Search engine for Magento catalog search functionality. <!-- OpenSearch is a search engine that provides search capabilities for the Magento catalog. -->
- Redis: Backend cache and session storage for improved performance. <!-- Redis is an in-memory data structure store, used as a database, cache, and message broker. -->
- Mailhog: Email testing tool for Magento email functionality. <!-- Mailhog is an email testing tool for Magento. -->
- PhpMyAdmin: Database management tool for MariaDB. <!-- PhpMyAdmin is a free and open-source administration tool for MySQL and MariaDB. -->

## Customization

You can customize your Docker setup by editing the docker-compose.yml and associated Dockerfiles for each service as needed. <!-- docker-compose.yml is a YAML file that defines services, networks, and volumes. Dockerfile is a text document that contains all the commands a user could call on the command line to assemble an image. -->

## Troubleshooting

- If you encounter permissions issues, ensure the ./magento and ./magento/pub directories are writable by the web server. <!-- This is a common issue where the web server does not have write permissions to the specified directories. -->
- For any errors during Magento installation, check the installation command for correctness and completeness. <!-- This is a common issue where the Magento installation command may be incorrect or incomplete. -->

## License

Magento Docker is available under the MIT License. <!-- The MIT License is a permissive free software license originating at the Massachusetts Institute of Technology (MIT). -->
