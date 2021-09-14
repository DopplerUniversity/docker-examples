# Using Doppler with Docker Compose for TLS and SSL Certificates in PEM Format

Doppler makes managing secrets for Docker Compose applications easy. This example will cover a reasonably complex use case of using Doppler to supply SSL/TLS certificates in PEM format to an application.

## Requirements

- [Doppler CLI](https://docs.doppler.com/docs/cli) installed and authenticated
- Docker Compose installed

To follow along with this tutorial, click on the **Import to Doppler** button below to create the Doppler project containing the required variables, including the TLS certificate and key.

<a href="https://dashboard.doppler.com/workplace/template/import?template=https%3A%2F%2Fgithub.com%2FDopplerUniversity%2Fdocker-examples%2Fblob%2Fmain%2Fdoppler-template.yaml"/><img src="https://raw.githubusercontent.com/DopplerUniversity/app-config-templates/main/doppler-button.svg" alt="Import to Doppler" /></a>

## Creating the Certificate and Key Secrets in Doppler

Use either the Doppler dashboard to copy and paste in the contents of your certificate and key, or the Doppler CLI as follows:

```sh
doppler secrets set CERT_PEM="$(cat ./tls.cert)"
doppler secrets set KEY_PEM="$(cat ./tls.key)"
```

## Docker Compose Environment Variables

Understanding [Docker Compose environment variables](https://docs.docker.com/compose/environment-variables/) can be confusing at first as variables expansion can happen on the host and inside the container.

For the most part, all you need to know is:

- Use `${VAR}` if you want variables expanded on the host
- Use `$${VAR}` if you want variables expanded inside the container.

Below is an example [`docker-compose.yaml`](docker-compose.yaml) for testing purposes that mounts a TLS certificate and key and uses the Open SSL CLI to print the certificate's metadata to verify that the certificate value from Doppler was valid.

```yaml
version: '3.9'
services:
  web:
    image: alpine
    container_name: doppler-pem-certificates
    working_dir: /usr/src/app
    init: true

    # Test command to validate the certificate
    command: ['/bin/sh', '-c', 'apk add openssl && openssl x509 -in $${DOCKER_SECRETS_DIR}/tls.cert -inform pem -noout -text']
    
    # Only variables explicitly defined will be passed through to the container
    environment:
      APP_URL: https://${HOSTNAME}:${PORT} # Example of creating a new environment variable using values from Doppler
      DOCKER_SECRETS_DIR: $DOCKER_SECRETS_DIR # Syntax for passing an envirionment variable form Doppler to the container
    
    # Generate tls.cert and tls.key files with Doppler CLI prior to running `docker-compose up`
    volumes:
      - $PWD/tls.cert:/usr/src/app/${DOCKER_SECRETS_DIR}/tls.cert
      - $PWD/tls.key:/usr/src/app/${DOCKER_SECRETS_DIR}/tls.key
```

> NOTE: An optimization we could perform here is using [Doppler's secret referencing](https://docs.doppler.com/docs/enclave-secrets#referencing-secrets) to replace the creation of `APP_URL` in the `docker-compose.yaml` file, using the exact same syntax.

## Using Doppler to Inject Environment Variables for Docker Compose

The most important thing to understand when using Doppler with Docker Compose is that only variables listed in the `environment` object (or list) will be passed through from Doppler to the container.

Once everything is in place, the Doppler CLI makes supplying environment variables, and certificates for Docker Compose a breeze, first extracting the certificate and key to the file system for mounting inside the container, then running `docker-compose up`:

```sh
doppler secrets get CERT_PEM --plain > tls.cert
doppler secrets get KEY_PEM --plain > tls.key
doppler run -- docker-compose up;
```

## Docker Compose Secrets Management in Production Environments

Configuring the  Doppler CLI for a Virtual Machine in production is done by scoping a [Doppler Service Token](https://docs.doppler.com/docs/enclave-service-tokens) to the file system location of your application code. The `DOPPLER_TOKEN` environment variable is required and should be injected securely through your CI-CD system, e.g., GitHub Action secrets.

Below is code you can incorporate as part of a Cloud-Init User-Data script. It uses Ubuntu, but other CLI installation commands are available from the [Doppler CLI Installation documentation](https://docs.doppler.com/docs/cli):

```sh
#!/bin/bash

# Install the Doppler CLI
apt-get update && apt-get install -y apt-transport-https ca-certificates curl gnupg
curl -sLf --retry 3 --tlsv1.2 --proto "=https" 'https://packages.doppler.com/public/cli/gpg.DE2A7741A397C129.key' | apt-key add -
echo "deb https://packages.doppler.com/public/cli/deb/debian any-version main" | tee /etc/apt/sources.list.d/doppler-cli.list
apt-get update && apt-get install -y doppler

# Scope service token to your application code directory

doppler configure set token $DOPPLER_TOKEN --scope /home/ubuntu/your-app

# Remove the Service Token set command from bash history to prevent leaking of raw service token value
history -c
```

## Summary

Awesome work! Now you know how to use Doppler with Docker Compose to simplify and securely manage secrets for your applications in any environment, from development to production.

Be sure to check out our [Docker Compose](https://docs.doppler.com/docs/enclave-docker-compose) documentation and reach out in our [Doppler Community Forum](https://community.doppler.com/) if you need help.

Originally published on the <a href="https://www.doppler.com/blog/docker-compose-tls-certificates" rel="canonical" >Doppler blog</a>.
