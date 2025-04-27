# Data Platform Engineering Case Study (Team One)

Welcome to the documentation for our case study project, where we successfully built a robust Data Platform for one of BuildItAll clients in Belgium. This Data platform was designed to facilitate big data analytics, empowering the clients to become more data-driven by efficiently handling the massive data they generate daily. Below, you will find a detailed description of the problem statement, solution approach, tools used, and the impact of the project on the business problem.

## Contributors
- [Nancy Amandi](https://github.com/Nancy9ice)
- [Best Nyah](https://github.com/Bee0933)
- [Abdulhakeem Salaudeen](https://github.com/HakeemSalaudeen)
- [David Dada](https://github.com/tdadadavid)


## Problem Statement

The BuildItAll team approached us on behalf of one of its clients from Belgium with the need to establish a Data Platform capable of supporting big data analytics. The goal was to enhance their data-driven decision-making processes by efficiently managing and analyzing the substantial volumes of data they produce every day.

## Solution Approach

![Architectural Diagram](<images/BuilditAll Architectural Diagram.png>)

Our solution involved establishing a comprehensive data platform, utilizing a variety of tools to ensure seamless data processing and analytics. 

## Tool Stack

- **AWS CloudWatch:** For resource monitoring
- **S3 Bucket:** For Data Storage
- **Pyspark (AWS EMR):** For Big Data Processing
- **Airflow (AMWAA):** For Data Orchestration
- **Terraform:** For Infrastructure Automation
- **GitHub Actions:** For CI-CD Deployment

Below is a step-by-step breakdown of our solution approach:

### 1. Configuration of CloudWatch Dashboard

CloudWatch was employed for monitoring purposes to track the performance of the resources that were provisioned on AWS, including tracking the performance of the Amazon Managed Workflows for Apache Airflow Service (AMWAA) DAGs where email alerts were sent on failure. This allowed us to promptly address any failures or issues within the workflow. This was provisioned using Terraform.

### 2. Creation of the Amazon S3 Bucket

The provisioned S3 bucket held different folders and files associated with the other resources provisioned on AWS including the cloudwatch metrics log files, AMWAA dags folder, AMWAA plugins folder, folder containing the pyspark scripts, AMWAA requirements file, and the folder containing the raw and processed forms of the dataset.This was also provisioned using Terraform.

### 3. Data Handling with Amazon S3
 Raw text data files in a zipped folder was downloaded programmatically from a [public link](https://archive.ics.uci.edu/static/public/507/wisdm+smartphone+and+smartwatch+activity+and+biometrics+dataset.zip) and stored in S3 bucket.

 ### 4. Data Processing with AWS EMR and PySpark

AWS EMR (Elastic MapReduce) was created and deployed for data processing tasks, leveraging PySpark scripts for efficient handling of large datasets. The Smartphone and Smartwatch Activity and Biometrics Dataset used contains accelerometer and gyroscope time-series sensor data from 51 test subjects performing 18 activities for 3 minutes each.

PySpark was utilized to retrieve the raw data from S3, process and transform it, and then push it back to S3 as Parquet files. This approach ensured scalability and reliability in handling over 15 million records.

### 5. Orchestrating with Apache Airflow

We used Apache Airflow to orchestrate the data pipeline. Initially, Airflow was tested locally to ensure stability and functionality before deploying it in production using AWS Managed Workflows for Apache Airflow (MWAA). It is important to note that the EMR cluster that hosted the execution of the pyspark scripts for data processing was created within Airflow and Terminated as soon as the data processing job was completed. Airflow's flexibility and ability to handle complex workflows made it an ideal choice for orchestrating our pipeline.

### 6. Infrastructure Deployment with Terraform

All infrastructure components were deployed in AWS using Terraform. Terraform's infrastructure-as-code approach allowed us to easily provision the required resources and resource dependencies, ensuring consistency and repeatability across environments.

### 7. Continuous Integration and Continuous Deployment (CI/CD) with GitHub Actions

We implemented a CI/CD pipeline using GitHub Actions which ensured that changes in the repository were tested before being deployed to Production.

To avoid rebuilding the pipelines due to unrelated code changes, our CI-CD pipeline was divided into two:

- **The Terraform CI-CD Deployment Pipeline**: 

This pipeline is only triggered when any changes were made to the Terraform folder only. It lints the terraform scripts, Validates and Format the terraform scripts, shows a preview of the resources that would be provisioned by Terraform and deployed. 

If there was a failure in any steps, resources that might have been provisioned before the failure would be destroyed. This avoids the sustained existence of resources that cannot be used.

- **The Airflow CI-CD Deployment Pipeline**:

This deployment pipeline runs only when changes are made to the Airflow folder containing our dags and pyspark scripts. This deployment pipeline involves the linting of the scripts, code testing using some basic unit tests by pytest that checks for some expectations in the dags. When these tests pass, the dag, pyspark, and requirements folder is redeployed to the s3 bucket so that the AMWAA service syncs any changes made.

Having these two different deployments ensured greater control over deployment and saves time too since running the two pipelines together everytime is slower than running just one if changes are made to just either of the Airflow or Terraform folder. The use of unit tests also ensured code quality in the context of the dags.

## Pros and Cons of Tools Used

### Pros

- **Apache Airflow**: Offers flexibility and scalability in orchestrating complex workflows.
- **Terraform**: Provides automation and version control for infrastructure deployments.
- **GitHub Actions**: Facilitates seamless CI/CD processes with automated testing.
- **AWS EMR**: Efficiently handles big data processing with PySpark integration.
- **Amazon S3**: Ensures reliable storage and retrieval of large datasets.
- **CloudWatch**: Provides robust monitoring capabilities for workflow management.

### Cons

- **Apache Airflow**: Initial setup can be complex and requires careful configuration.
- **Terraform**: Requires familiarity with infrastructure-as-code concepts for effective use.
- **GitHub Actions**: May involve a learning curve for setting up complex workflows.
- **AWS EMR**: Cost considerations for extensive usage
- **Amazon S3**: Requires management of storage costs as data volume increases.
- **CloudWatch**: Can incur additional costs for extensive monitoring.

## Repository Structure

```bash
├── .github/  # Holds the github workflow yaml files and pull_request template

├── airflow/  # Holds the airflow dags and pyspark scripts

├── terraform/  # Holds the terraform scripts that automatically provisions aws resources

├── .gitignore  # Lists irrelevant files to be ignored

├── README.md  # Documentation

├── fix-flake.sh # Fixes any code quality issues in files in the airflow folder
```

## Environment Setup

Before starting, ensure you have:

* An AWS account 
* VS Code 
* Terraform v1.10.4+ installed
* AWS CLI installed and configured
* Airflow (for local testing)

**Clone the Repository**:
   ```bash
   git clone https://github.com/Nancy9ice/Data_Platform_Engineering_Case_Study
   ```
**Create branch for development**
```bash
git checkout -b /your-branch-name
   ```
**Install dependencies**
   ```bash
   pip install -r requirements.txt
   ```

**Configure AWS CLI with your credentials**
   ```bash
   aws configure
   ```

**Create necessary S3 buckets**
```bash
aws s3 mb s3://your-project-airflow-dags
aws s3 mb s3://your-project-raw-data
aws s3 mb s3://your-project-processed-data
   ```

**Data Preparation**
```bash
#Create a directory
mkdir -p data/raw

# Download sample data (replace with your source)
wget -O data/raw/dataset.zip [https://archive.ics.uci.edu/static/public/507/wisdm+smartphone+and+smartwatch+activity+and+biometrics+dataset.zip]

# Upload data to S3
aws s3 sync data/raw/ s3://your-project-raw-data/
   ```

## Impact on Business Problem

The implementation of this Data Platform has significantly impacted BuildItAll client's ability to be more data-driven. 

By enabling efficient big data analytics, the client can now derive actionable insights from their massive datasets, leading to improved decision-making processes. The automation and optimization strategies employed reduced manual intervention, increased operational efficiency, and provided a scalable solution to handle future data growth.

## Conclusion

This case study project demonstrates our commitment to delivering high-quality solutions that address complex business needs. By leveraging cloud technologies and best practices, we successfully built a Data Platform that empowers BuildItAll clients to harness the power of big data analytics.
