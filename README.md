# todolist-config

Kubernetes deployment configuration files for https://github.com/Well5a/todolist

## Metrics Monitoring

* Prometheus: http://localhost:9090
* Grafana: http://localhost:3000
* Grafana login: user=admin password=todo

### Add datasources in Grafana

Dashboards and datasources are added and updated automatically through config files in the folder "grafana>provisioning".
If you need to add datasources manually these are the necessary credentials:

* Prometheus: URL=http://prometheus:9090
* PostgreSQL: host=todo-db:5432 database=tododb user=todo password=todo ssl=disable

### InspectIT Ocelot

[InspectIT Ocelot](https://github.com/inspectIT/inspectit-ocelot) collects metrics of the application and exposes them by default on port 8888.
Prometheus is configured to scrape this endpoint and additional Grafana Dashboards are added that use these metrics.

The InspectIT Ocelot Docker image saves the agent jar on a provided volume.
Other microservices can access this volume to get the agent and inject it via an overwritten entrypoint.

### PostgreSQL Exporter (database metrics)

PostgreSQL saves various metrics about the database server in form of a set of tables (e.g. with the [Statistics Collector](https://www.postgresql.org/docs/11/monitoring-stats.html)).
The [PostgreSQL Exporter](https://github.com/wrouesnel/postgres_exporter) exports and exposes these metrics on default port 9187 for use by Prometheus.
A dashboard for these metrics is also included.

## Kubernetes and Azure Cloud

Folder "kubernetes" holds config files for deploying the app with Prometheus and Grafana to a Kubernetes cluster.
The todo-service includes the app, the database and the database metric exporter.

The sub folders "azure" and "minikube" hold scripts to create the app on Azure Cloud and local Minikube installation respectively.

The Folder "Kompose" holds Kubernetes config files generated with [Kompose](http://kompose.io/).
These files won't create a working application and were merely used as templates.

### Prerequisites for Azure

* local [kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl/) installation
* local [Azure CLI](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli?view=azure-cli-latest) installation
* Azure account

### Deploying on Azure

Simply execute the createResources.sh script.
This automatically creates the necessary ressources on your Azure cloud like storage shares and the Kubernetes cluster.
Afterwards it deploys the app which will then be reachable on the external endpoints of the Kubernetes services.
Because the script also sets this cluster as the default instance of your local kubectl installation you can simply execute `kubectl get services` to get a list of the Kubernetes services and their available endpoints.

Note that at one point in the execution of the script you will be asked for root permissions.
This is necessary to install kubectl for the Azure CLI.
However this needs to be done only once so you could also install it manually before executing the script for the first time and comment the line out.

### Deploying on another cloud provider or locally

Per default the Kubernetes files are configured to use Azure resources.
If you want to deploy to another cloud provider or on a local environment like Minikube you have to change some lines of code.
The following list shows the Kubernetes config files that need changes and how to take care of them:

* grafana-k8.yml: The grafana deployment uses the Azure File volume implementation for the dashboards and dashboard config.
    Change this to an appropriate [volume implementation](https://kubernetes.io/docs/concepts/storage/volumes/#types-of-volumes) of your desired cloud provider.
    Alternatively use the "hostpath" implementation for a local cluster that was commented out.
* inspectit-k8.yml: The Persistent Volume Claim uses the default storage class in the Kubernetes cluster.
    The identification of the storage class can differ depending on Kubernetes installation.
    For example on Azure it is called "default" whereas Minikube is using "standard" as the identifier.

### Deploying with Minikube

For testing or development purposes a local Kubernetes instance like [Minikube](https://kubernetes.io/docs/setup/minikube/) is often useful.

You need a working Minikube installation, after that execute the create.sh script to create the Kubernetes resources on the cluster.
The app will become available on the internal-IP of the cluster node (get it with `kubectl get node -o wide`).

For access to services of type LoadBalancer with Minikube you have to run `minikube tunnel` in a seperate command line window.
Then the External IPs will become available.

With Minikube you can access a dashboard that shows the availability of your cluster and the resources within.
Command `kubectl proxy` provides this dashboard at localhost:8001.
