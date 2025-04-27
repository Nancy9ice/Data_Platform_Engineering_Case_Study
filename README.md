# Data Platform Engineering Case Study (Team One)

Welcome to the documentation for our case study project, where we successfully built a robust Data Platform for BuildItAll clients in Belgium. This platform was designed to facilitate big data analytics, empowering the clients to become more data-driven by efficiently handling the massive data they generate daily. Below, you will find a detailed description of the problem statement, solution approach, tools used, and the impact of the project on the business problem.

## Contributors
- [Nancy Amandi](https://github.com/Nancy9ice)
- [Best Nyah](https://github.com/Bee0933)
- [Abdulhakeem Salaudeen](https://github.com/HakeemSalaudeen)
- [David Dada](https://github.com/tdadadavid)



## Problem Statement

BuildItAll clients from Belgium approached us with the need to establish a Data Platform capable of supporting big data analytics. The goal was to enhance their data-driven decision-making processes by efficiently managing and analyzing the substantial volumes of data they produce every day.

## Solution Approach

Our solution involved establishing a comprehensive data pipeline, utilizing a variety of tools to ensure seamless data processing and analytics. Below is a step-by-step breakdown of our approach:

### 1. Orchestrating with Apache Airflow

We used Apache Airflow to orchestrate the data pipeline. Initially, Airflow was tested locally to ensure stability and functionality before deploying it in production using AWS Managed Workflows for Apache Airflow (MWAA). Airflow's flexibility and ability to handle complex workflows made it an ideal choice for orchestrating our pipeline.

### 2. Infrastructure Deployment with Terraform

All infrastructure components were deployed in AWS using Terraform. Terraform's infrastructure-as-code approach allowed us to automate and version control our deployments, ensuring consistency and repeatability across environments.

### 3. Continuous Integration and Continuous Deployment (CI/CD) with GitHub Actions

We implemented a CI/CD pipeline using GitHub Actions. This facilitated automated testing and deployment, ensuring that all changes were thoroughly vetted before merging into the main branch. The integration of flake8 linting helped maintain code quality.

### 4. Data Processing with AWS EMR and PySpark

AWS EMR was deployed for data processing tasks, leveraging PySpark scripts for efficient handling of large datasets. The Smartphone and Smartwatch Activity and Biometrics Dataset was used, which contains accelerometer and gyroscope time-series sensor data from 51 test subjects performing 18 activities for 3 minutes each.

### 5. Data Handling with Amazon S3

The dataset was downloaded and stored in Amazon S3. PySpark was utilized to retrieve data from S3, process and transform it, and then push it back to S3 as Parquet files. This approach ensured scalability and reliability in handling over 15 million records.

### 6. Monitoring with CloudWatch

CloudWatch was employed for monitoring purposes, particularly to track the performance of MWAA DAGs stored in S3. This allowed us to promptly address any failures or issues within the workflow.

### 7. Spark Optimization Strategy

A Spark optimization strategy was implemented to enhance the performance of Spark jobs, ensuring efficient processing of large datasets.

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
- **AWS EMR**: Cost considerations for extensive usage.
- **Amazon S3**: Requires management of storage costs as data volume increases.
- **CloudWatch**: Can incur additional costs for extensive monitoring.

## Impact on Business Problem

The implementation of this Data Platform has significantly impacted BuildItAll clients' ability to be more data-driven. By enabling efficient big data analytics, clients can now derive actionable insights from their massive datasets, leading to improved decision-making processes. The automation and optimization strategies employed have reduced manual intervention, increased operational efficiency, and provided a scalable solution to handle future data growth.

## Conclusion

This case study project demonstrates our commitment to delivering high-quality solutions that address complex business needs. By leveraging cutting-edge technologies and best practices, we successfully built a Data Platform that empowers BuildItAll clients to harness the power of big data analytics. 
