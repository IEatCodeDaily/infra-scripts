# Komodo Helm Chart

This Helm chart deploys the Komodo application with a PostgreSQL backend, including the necessary services and configurations.

## Prerequisites

- Kubernetes cluster (v1.16+)
- Helm (v3.0+)

## Installation

To install the Komodo Helm chart, use the following command:

```bash
helm install <release-name> ./komodo-helm-chart
```

Replace `<release-name>` with your desired release name.

## Configuration

The following configuration options are available in the `values.yaml` file:

- `komodo.image.tag`: Specify the image tag for the Komodo Core and Periphery services.
- `postgres.image.tag`: Specify the image tag for the PostgreSQL database.
- `komodo.db.username`: Set the username for the PostgreSQL database.
- `komodo.db.password`: Set the password for the PostgreSQL database.
- `komodo.db.name`: Set the name of the PostgreSQL database.

## Upgrading

To upgrade an existing release, use the following command:

```bash
helm upgrade <release-name> ./komodo-helm-chart
```

## Uninstallation

To uninstall the Komodo release, run:

```bash
helm uninstall <release-name>
```

## Notes

- Ensure that your Kubernetes cluster has sufficient resources to run the Komodo application and its dependencies.
- For more detailed configuration options, refer to the `values.yaml` file.

## License

This project is licensed under the MIT License. See the LICENSE file for more details.