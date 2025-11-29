# Xdebug Configuration Guide

This guide explains how to configure and use Xdebug for debugging your Magento 2 application with the FrankenPHP Docker environment.

## Prerequisites

- Use the **development image** (`mohelmrabet/magento-frankenphp:dev` or `php8.4-fp1.10.1-dev`)
- PHPStorm, VS Code, or another IDE with Xdebug support

## Default Configuration

The development image comes with Xdebug pre-configured with the following settings:

```ini
xdebug.mode = debug
xdebug.client_host = host.docker.internal
xdebug.client_port = 9003
xdebug.start_with_request = trigger
xdebug.idekey = PHPSTORM
```

## Using the Development Image

Make sure your `docker-compose.yml` uses the dev image:

```yaml
services:
  app:
    image: mohelmrabet/magento-frankenphp:php8.4-fp1.10.1-dev
    # or simply use the 'dev' tag:
    # image: mohelmrabet/magento-frankenphp:dev
```

## IDE Configuration

### PHPStorm Setup

1. **Configure Xdebug Port**
   - Go to **Settings > PHP > Debug**
   - Set **Xdebug port** to `9003`
   - Enable **Can accept external connections**

2. **Configure Server Mapping**
   - Go to **Settings > PHP > Servers**
   - Click **+** to add a new server:
     - **Name**: `magento.localhost` (or your `SERVER_NAME`)
     - **Host**: `magento.localhost`
     - **Port**: `443`
     - **Debugger**: `Xdebug`
     - **Use path mappings**: ✅ Yes
     - Map `/var/www/html` → your local `src/` directory

3. **Start Listening**
   - Go to **Run > Start Listening for PHP Debug Connections** in the menu
   - Or click the **Start Listening for PHP Debug Connections** button in the toolbar (looks like a phone or bug icon, depending on PHPStorm version)
   - Or use the keyboard shortcut: `Ctrl+Alt+D` (Windows/Linux) / `Cmd+Alt+D` (macOS)

### VS Code Setup

1. **Install PHP Debug Extension**
   - Install the [PHP Debug](https://marketplace.visualstudio.com/items?itemName=xdebug.php-debug) extension by Xdebug

2. **Create Launch Configuration**
   - Create `.vscode/launch.json` in your project root:

```json
{
    "version": "0.2.0",
    "configurations": [
        {
            "name": "Listen for Xdebug",
            "type": "php",
            "request": "launch",
            "port": 9003,
            "pathMappings": {
                "/var/www/html": "${workspaceFolder}/src"
            }
        }
    ]
}
```

3. **Start Debugging**
   - Go to **Run and Debug** panel (Ctrl+Shift+D / Cmd+Shift+D)
   - Select "Listen for Xdebug" from the dropdown
   - Click the green play button ▶️

## Triggering Xdebug

Since `xdebug.start_with_request = trigger` is configured (for performance), you need to trigger Xdebug manually:

### Option 1: URL Parameter

Add `?XDEBUG_SESSION=PHPSTORM` to any URL:

```
https://magento.localhost/?XDEBUG_SESSION=PHPSTORM
https://magento.localhost/admin?XDEBUG_SESSION=PHPSTORM
```

### Option 2: Browser Extension (Recommended)

Install a browser extension that automatically manages the Xdebug session:

- **Chrome**: [Xdebug Helper](https://chrome.google.com/webstore/detail/xdebug-helper/eadndfjplgieldjbigjakmdgkmoaaaoc)
- **Firefox**: [Xdebug Helper](https://addons.mozilla.org/en-US/firefox/addon/xdebug-helper-for-firefox/)
- **Edge**: [Xdebug Helper](https://microsoftedge.microsoft.com/addons/detail/xdebug-helper/ggnngifabofaddiejjeagbaebkejomen)

Configure the extension:
1. Right-click the extension icon and select **Options**
2. Set **IDE key** to `PHPSTORM` (or your IDE key)
3. Click the extension icon and select **Debug** when you want to debug

### Option 3: Cookie

Set a cookie named `XDEBUG_SESSION` with value `PHPSTORM`:

```javascript
document.cookie = "XDEBUG_SESSION=PHPSTORM; path=/";
```

## Debugging CLI Commands

To debug Magento CLI commands (e.g., `bin/magento`), you need to enable Xdebug explicitly:

```bash
# Enter the container
docker compose exec app bash

# Run command with Xdebug enabled
XDEBUG_SESSION=1 bin/magento cache:flush
```

Or from outside the container:

```bash
docker compose exec -e XDEBUG_SESSION=1 app bin/magento cache:flush
```

## Customizing Xdebug Configuration

### Override Configuration

Mount a custom `xdebug.ini` file to override default settings:

```yaml
services:
  app:
    volumes:
      - ./conf/xdebug.ini:/usr/local/etc/php/conf.d/zz-xdebug.ini:ro
```

Create `conf/xdebug.ini`:

```ini
xdebug.mode = debug
xdebug.client_host = host.docker.internal
xdebug.client_port = 9003
xdebug.start_with_request = yes
xdebug.idekey = PHPSTORM
xdebug.log = /tmp/xdebug.log
```

### Available Xdebug Modes

| Mode | Description |
|------|-------------|
| `off` | Disable Xdebug |
| `debug` | Step debugging |
| `develop` | Development helpers (var_dump improvements) |
| `coverage` | Code coverage for PHPUnit |
| `profile` | Performance profiling |
| `trace` | Function trace |

You can combine modes: `xdebug.mode = debug,develop`

## Troubleshooting

### Xdebug Not Connecting

1. **Verify Xdebug is installed**:
   ```bash
   docker compose exec app php -v
   # Should show "with Xdebug v3.x.x"
   ```

2. **Check Xdebug configuration**:
   ```bash
   docker compose exec app php -i | grep xdebug
   ```

3. **Verify port is open** on your host:
   - Make sure your IDE is listening on port 9003
   - Check firewall settings

4. **Enable Xdebug logging**:
   Add to your custom xdebug.ini:
   ```ini
   xdebug.log = /tmp/xdebug.log
   xdebug.log_level = 7
   ```
   Then check the log:
   ```bash
   docker compose exec app cat /tmp/xdebug.log
   ```

### Connection Refused on Linux

On Linux, `host.docker.internal` might not resolve correctly. Use your host's IP:

1. Find your Docker bridge IP:
   ```bash
   ip addr show docker0
   ```

2. Override client host:
   ```ini
   xdebug.client_host = 172.17.0.1  # Replace with your IP
   ```

Or add this to your `docker-compose.yml`:

```yaml
services:
  app:
    extra_hosts:
      - "host.docker.internal:host-gateway"
```

### Breakpoints Not Working

1. **Verify path mappings** - The container path `/var/www/html` must be correctly mapped to your local `src/` directory
2. **Clear cache** - Magento may have cached the old paths
3. **Check file permissions** - Ensure the debugged files are readable

### Performance Impact

Xdebug can slow down your application. For better performance:

1. Use `trigger` mode instead of `yes`:
   ```ini
   xdebug.start_with_request = trigger
   ```

2. Disable Xdebug when not needed:
   ```bash
   # Create a docker-compose.override.yml for production-like testing
   docker compose -f docker-compose.yml -f docker-compose.prod.yml up -d
   ```

## See Also

- [Configuration Guide](configuration.md) - Environment variables and settings
- [Local Development Guide](../examples/local-development.md) - Complete development setup
- [Xdebug Official Documentation](https://xdebug.org/docs/)
