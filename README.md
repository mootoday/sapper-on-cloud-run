[![Gitpod Ready-to-Code](https://img.shields.io/badge/Gitpod-Ready--to--Code-blue?logo=gitpod)](https://gitpod.io/#https://github.com/mikenikles/sapper-on-cloud-run) 

# sapper-on-cloud-run
A boilerplate to deploy Sapper (Svelte) applications to Cloud Run (https://cloud.run)

A demo is available at https://sapper-on-cloud-run.mikenikles.com/.

## Blog posts

Two corresponding blog posts are available with details:
* [Sapper, Google Cloud Run, Continuous Deployment - A boilerplate template](https://www.mikenikles.com/blog/sapper-google-cloud-run-continuous-deployment-a-boilerplate-template)
* [Firebase Hosting for static assets of a Sapper web app on Cloud Run](https://www.mikenikles.com/blog/firebase-hosting-for-static-assets-of-a-sapper-web-app-on-cloud-run)
    * Also check [PR #5](https://github.com/mikenikles/sapper-on-cloud-run/pull/5)

## Docker local testing

The following NPM scripts assist with testing the container image locally:
* `npm run dev:docker:build`: Builds the docker image.
* `npm run dev:docker:run`: Runs the docker image locally on port 3000.

## Set up the Artifact Registry

```sh
# Enable the Artifact Registry API
gcloud services enable artifactregistry.googleapis.com

# Create an Artifact Registry repository to host docker images
gcloud beta artifacts repositories create docker-repository --repository-format=docker \
--location=us-central1
```

## Set up Cloud Build

```sh
# Enable the Cloud Build API
gcloud services enable cloudbuild.googleapis.com

# Create a build trigger
gcloud beta builds triggers create github \
--repo-name=sapper-on-cloud-run \
--repo-owner=mikenikles \
--branch-pattern="^master$" \
--build-config=cloudbuild.yaml
```

## Set up Cloud Run

```sh
# Obtain the numeric project ID
# Use: gcloud projects list --filter="$(gcloud config get-value project)" --format="value(PROJECT_NUMBER)"

# Grant the Cloud Run Admin role
gcloud projects add-iam-policy-binding $PROJECT_ID \
  --member "serviceAccount:PROJECT_NUMBER@cloudbuild.gserviceaccount.com" \
  --role roles/run.admin

# Grant access to Cloud Build to deploy to Cloud Run
gcloud iam service-accounts add-iam-policy-binding \
  PROJECT_NUMBER-compute@developer.gserviceaccount.com \
  --member="serviceAccount:PROJECT_NUMBER@cloudbuild.gserviceaccount.com" \
  --role="roles/iam.serviceAccountUser"
```

## Deploy to Cloud Run

Cloud Run (https://cloud.run) is a fully managed serverless compute platform that automatically
scales your stateless containers.

The continuous deployment pipeline works as follows:
1. Merge a pull request into the `master` branch.
1. The [Cloud Build GitHub app](https://github.com/marketplace/google-cloud-build) triggers Cloud Build to:
    1. Build the docker image
    1. Push the docker image to [Artifact Registry](https://cloud.google.com/artifact-registry)
    1. Deploy the image to [Cloud Run](https://cloud.google.com/run)

### Mapping a custom domain

Details on how to verify a domain can be found [in the documentation](https://cloud.google.com/run/docs/mapping-custom-domains).

Once a domain is verified, the following command maps it to a Cloud Run service:

```sh
gcloud beta run domain-mappings create \
  --service sapper-on-cloud-run \
  --domain sapper-on-cloud-run.mikenikles.com \
  --region us-central1 \
  --platform managed
```

Add a CNAME record with name `sapper-on-cloud-run` and contents `ghs.googlehosted.com` to your DNS.
