# Security Policy

## Supported Versions

The following versions of this Docker template are currently supported with security updates:

| Version | Supported          |
| ------- | ------------------ |
| 1.0.x   | :white_check_mark: |

## Reporting a Vulnerability

We take security seriously. If you discover a security vulnerability within this project, please follow these steps:

### How to Report

1. **Do NOT** open a public GitHub issue for security vulnerabilities
2. Send an email to: `contact@cleatsquad.dev`
3. Include in your report:
   - Description of the vulnerability
   - Steps to reproduce
   - Potential impact
   - Suggested fix (if any)

### What to Expect

- **Acknowledgment**: Within 48 hours of your report
- **Status Update**: Within 7 days with our assessment
- **Resolution**: Security fixes are prioritized and typically released within 14 days

### Disclosure Policy

- We follow responsible disclosure practices
- We will coordinate with you on the disclosure timeline
- Credit will be given to reporters (unless anonymity is requested)

## Security Best Practices

When using this template in production, follow these security guidelines:

### 1. Environment Variables & Secrets

```bash
# NEVER commit .env files
# Run ./bin/setup to copy env templates

# Required environment variables for production:
MYSQL_ROOT_PASSWORD=<strong-unique-password>
DB_PASSWORD=<strong-unique-password>
RABBITMQ_DEFAULT_PASS=<strong-unique-password>
```

**Best Practices:**
- Use unique, strong passwords (min 16 characters)
- Rotate credentials regularly
- Use secrets management (HashiCorp Vault, AWS Secrets Manager, etc.)
- Never log or expose credentials

### 2. Docker Security

```yaml
# Security options already configured in docker-compose files:
security_opt:
  - no-new-privileges:true

# Additional recommendations:
# - Run containers as non-root user (www-data)
# - Use read-only file systems where possible
# - Limit container capabilities
```

### 3. Network Security

- Use external networks only when necessary
- Configure firewall rules to limit exposed ports
- Use TLS/SSL for all communications
- Consider using a Web Application Firewall (WAF)

### 4. SSL/TLS Configuration

**Development:**
```bash
# Generate local trusted certificates with mkcert
./bin/setup-ssl
```

**Production:**
- Let Caddy handle automatic HTTPS (recommended)
- Or use your own certificates:
```yaml
environment:
  CADDY_TLS_CONFIG: "/path/to/cert.pem /path/to/key.pem"
```

### 5. Database Security

- Use dedicated database users with minimal privileges
- Never expose database ports publicly (remove port mapping in prod)
- Enable SSL connections for database
- Regular backups with encryption
- Use strong passwords

### 6. File Permissions

```bash
# Ensure proper ownership
./bin/fixowns

# Set correct permissions
./bin/fixperms

# Magento recommended permissions:
# - Directories: 755
# - Files: 644
# - var/, generated/, pub/static/: 775 (or 777 in dev)
```

### 7. Magento Security

- Keep Magento updated to the latest security patches
- Enable Admin Two-Factor Authentication in production
- Use Content Security Policy (CSP)
- Regularly review admin users and API tokens
- Enable and configure Web Application Firewall

### 8. OpenSearch Security

For production, consider enabling OpenSearch security plugin:
```bash
# In env/opensearch.env
DISABLE_SECURITY_PLUGIN=false
```

And configure proper authentication and TLS.

### 9. Regular Updates

- Keep all Docker images updated
- Monitor security advisories for:
  - Magento: https://helpx.adobe.com/security/products/magento.html
  - FrankenPHP: https://github.com/dunglas/frankenphp/security
  - PHP: https://www.php.net/security
  - MariaDB: https://mariadb.com/kb/en/security/
  - OpenSearch: https://opensearch.org/docs/latest/security/

### 10. Monitoring & Logging

- Enable comprehensive logging
- Monitor for unusual activity
- Set up alerts for security events
- Regular security audits

## Docker Image Security

The base images used in this template are:

| Image | Source | Security Updates |
|-------|--------|------------------|
| mohelmrabet/magento-frankenphp | Docker Hub | Regular updates |
| mariadb:11.4 | Official | LTS support |
| opensearch:2.14 | Official | Regular updates |
| valkey:8.1 | Official | Regular updates |
| rabbitmq:4.1 | Official | Regular updates |

## Production Checklist

Before deploying to production:

- [ ] All default passwords changed
- [ ] `.env` file configured and not in version control
- [ ] SSL/TLS properly configured
- [ ] Database ports not exposed
- [ ] Admin URLs changed from default
- [ ] Two-Factor Authentication enabled
- [ ] Security headers configured
- [ ] Backups configured and tested
- [ ] Monitoring and alerting set up
- [ ] Security logging enabled
- [ ] Rate limiting configured
- [ ] DDoS protection in place

## Security Resources

- [Magento Security Best Practices](https://experienceleague.adobe.com/docs/commerce-operations/implementation-playbook/best-practices/launch/security-best-practices.html)
- [Docker Security Best Practices](https://docs.docker.com/develop/security-best-practices/)
- [OWASP Web Security Testing Guide](https://owasp.org/www-project-web-security-testing-guide/)
- [CIS Docker Benchmark](https://www.cisecurity.org/benchmark/docker)

## Contact

For security-related inquiries: `contact@cleatsquad.dev`
