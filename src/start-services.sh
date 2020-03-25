## create namespace
kubectl apply -f namespace.yml

## Add postgres chart repo
helm repo add bitnami https://charts.bitnami.com/bitnami

## Start postgres
helm install notes-app-postgres --namespace notes-app -f postgres-config.yml bitnami/postgresql

## Delete postgres
## helm delete notes-app-postgres --namespace notes-app

## Port forward
# kubectl port-forward --namespace notes-app svc/notes-app-postgres-postgresql 5433:5432

# kubectl port-forward --namespace notes-app svc/notes-app-server 8081:8080

## Setup deployment
kubectl apply -f deployment.yml

## Delete deployment
## kubectl delete -f deployment.yml
